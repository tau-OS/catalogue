/* core/flatpak_backend.vala
 *
 * Copyright 2022 Fyra Labs
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


namespace Catalogue.Core {
    public class FlatpakPackage : Package {
        public weak Flatpak.Installation installation { public get; construct; }

        public FlatpakPackage (Flatpak.Installation installation, AppStream.Component component) {
            Object (
                installation: installation,
                component: component
            );
        }
    }

    public class FlatpakBackend : Object {
        // Based on https://github.com/flatpak/flatpak/blob/417e3949c0ecc314e69311e3ee8248320d3e3d52/common/flatpak-run-private.h
        private const string FLATPAK_METADATA_GROUP_APPLICATION = "Application";
        private const string FLATPAK_METADATA_KEY_RUNTIME = "runtime";

        // AppStream data has to be 1 hour old before it's refreshed
        public const uint MAX_APPSTREAM_AGE = 3600;

        private AsyncQueue<Job> jobs = new AsyncQueue<Job> ();
        private Thread<bool> worker_thread;

        private Gee.HashMap<string, Package> package_list;
        private AppStream.Pool user_appstream_pool;
        private AppStream.Pool system_appstream_pool;

        // This is OK as we're only using a single thread
        // This would have to be done differently if there were multiple workers in the pool
        private bool thread_should_run = true;

        public bool working { public get; protected set; }

        private string user_metadata_path;
        private string system_metadata_path;

        public static Flatpak.Installation? user_installation { get; private set; }
        public static Flatpak.Installation? system_installation { get; private set; }

        private bool worker_func () {
            while (thread_should_run) {
                var job = jobs.pop ();
                working = true;
                switch (job.operation) {
                    case Job.Type.REFRESH_CACHE:
                        refresh_cache_internal (job);
                        break;
                    default:
                        assert_not_reached ();
                }
    
                working = false;
            }
    
            return true;
        }

        construct {
            worker_thread = new Thread<bool> ("flatpak-worker", worker_func);

            package_list = new Gee.HashMap<string, Package> ();

            user_appstream_pool = new AppStream.Pool ();
            user_appstream_pool.set_flags (AppStream.PoolFlags.LOAD_OS_COLLECTION);

            system_appstream_pool = new AppStream.Pool ();
            system_appstream_pool.set_flags (AppStream.PoolFlags.LOAD_OS_COLLECTION);

            user_metadata_path = Path.build_filename (
                Environment.get_user_cache_dir (),
                Config.APP_ID,
                "flatpak-metadata",
                "user"
            );
    
            system_metadata_path = Path.build_filename (
                Environment.get_user_cache_dir (),
                Config.APP_ID,
                "flatpak-metadata",
                "system"
            );
    
            reload_appstream_pool ();
        }

        static construct {
            try {
                user_installation = new Flatpak.Installation.user ();
            } catch (Error e) {
                critical ("Unable to get flatpak user installation : %s", e.message);
            }
    
            try {
                system_installation = new Flatpak.Installation.system ();
            } catch (Error e) {
                warning ("Unable to get flatpak system installation : %s", e.message);
            }
        }

        ~FlatpakBackend () {
            thread_should_run = false;
            worker_thread.join ();
        }

        private async Job launch_job (Job.Type type, JobArgs? args = null) {
            var job = new Job (type);
            job.args = args;

            SourceFunc callback = launch_job.callback;
            job.results_ready.connect (() => {
                Idle.add ((owned) callback);
            });

            jobs.push (job);
            yield;
            return job;
        }

        public async Gee.Collection<Package> get_installed_applications (Cancellable? cancellable = null) {
            var installed_apps = new Gee.HashSet<Package> ();
    
            if (user_installation == null && system_installation == null) {
                critical ("Couldn't get installed apps due to no flatpak installation");
                return installed_apps;
            }
    
            GLib.GenericArray<weak Flatpak.InstalledRef> installed_refs;
            try {
                installed_refs = user_installation.list_installed_refs ();
                installed_apps.add_all (get_installed_apps_from_refs (false, installed_refs, cancellable));
            } catch (Error e) {
                critical ("Unable to get installed flatpaks: %s", e.message);
                return installed_apps;
            }
    
            try {
                installed_refs = system_installation.list_installed_refs ();
                installed_apps.add_all (get_installed_apps_from_refs (true, installed_refs, cancellable));
            } catch (Error e) {
                critical ("Unable to get installed flatpaks: %s", e.message);
                return installed_apps;
            }
            
    
            return installed_apps;
        }

        private Gee.Collection<Package> get_installed_apps_from_refs (bool system, GLib.GenericArray<weak Flatpak.InstalledRef> installed_refs, Cancellable? cancellable) {
            var installed_apps = new Gee.HashSet<Package> ();
    
            for (int i = 0; i < installed_refs.length; i++) {
                if (cancellable.is_cancelled ()) {
                    break;
                }
    
                unowned Flatpak.InstalledRef installed_ref = installed_refs[i];
    
                var bundle_id = generate_package_list_key (system, installed_ref.origin, installed_ref.format_ref ());
                var package = package_list[bundle_id];
                if (package != null) {
                    package.mark_installed ();
                    package.update_state ();
                    installed_apps.add (package);
                }
            }
    
            return installed_apps;
        }

        public Gee.Collection<Package> get_applications_for_category (AppStream.Category category) {
            unowned GLib.GenericArray<AppStream.Component> components = category.get_components ();
            // Clear out any cached components that could be from other backends
            if (components.length != 0) {
                components.remove_range (0, components.length);
            }
    
            var category_array = new GLib.GenericArray<AppStream.Category> ();
            category_array.add (category);
            AppStream.utils_sort_components_into_categories (user_appstream_pool.get_components (), category_array, false);
            AppStream.utils_sort_components_into_categories (system_appstream_pool.get_components (), category_array, false);
            components = category.get_components ();
    
            var apps = new Gee.TreeSet<Package> ();
            components.foreach ((comp) => {
                var packages = get_packages_for_component_id (comp.get_id ());
                apps.add_all (packages);
            });
    
            return apps;
        }

        public Package? get_package_for_component_id (string id) {
            var suffixed_id = id + ".desktop";

            if (package_list.values != null) {
                foreach (var package in package_list.values) {
                    if (package.component.id == id) {
                        return package;
                    } else if (package.component.id == suffixed_id) {
                        return package;
                    }
                }
            }            
    
            return null;
        }

        public Gee.Collection<Package> get_packages_for_component_id (string id) {
            var packages = new Gee.ArrayList<Package> ();
            var suffixed_id = id + ".desktop";
            foreach (var package in package_list.values) {
                if (package.component.id == id) {
                    packages.add (package);
                } else if (package.component.id == suffixed_id) {
                    packages.add (package);
                }
            }
    
            return packages;
        }

        private void reload_appstream_pool () {
            user_appstream_pool.reset_extra_data_locations ();
            user_appstream_pool.add_extra_data_location (user_metadata_path, AppStream.FormatStyle.COLLECTION);

            try {
                debug ("Loading Flatpak user pool");
                user_appstream_pool.load ();
            } catch (Error e) {
                warning ("Errors found in flatpak appdata, some components may be incomplete/missing: %s", e.message);
            } finally {
                user_appstream_pool.get_components ().foreach ((comp) => {
                    var bundle = comp.get_bundle (AppStream.BundleKind.FLATPAK);
                    if (bundle != null) {
                        var key = generate_package_list_key (false, comp.get_origin (), bundle.get_id ());
                        var package = package_list[key];
                        if (package != null) {
                            package.replace_component (comp);
                        } else {
                            package = new FlatpakPackage (user_installation, comp);
                        }

                        package_list[key] = package;
                    }
                });
            }

            system_appstream_pool.reset_extra_data_locations ();
            system_appstream_pool.add_extra_data_location (system_metadata_path, AppStream.FormatStyle.COLLECTION);

            try {
                debug ("Loading Flatpak system pool");
                system_appstream_pool.load ();
            } catch (Error e) {
                warning ("Errors found in flatpak appdata, some components may be incomplete/missing: %s", e.message);
            } finally {
                system_appstream_pool.get_components ().foreach ((comp) => {
                    var bundle = comp.get_bundle (AppStream.BundleKind.FLATPAK);
                    if (bundle != null) {
                        var key = generate_package_list_key (true, comp.get_origin (), bundle.get_id ());
                        var package = package_list[key];
                        if (package != null) {
                            package.replace_component (comp);
                        } else {
                            package = new FlatpakPackage (system_installation, comp);
                        }

                        package_list[key] = package;
                    }
                });
            }
        }

        public void preprocess_metadata (bool system, GLib.GenericArray<weak Flatpak.Remote> remotes, Cancellable? cancellable) {
            unowned Flatpak.Installation installation;
    
            unowned string dest_path;
            if (system) {
                dest_path = system_metadata_path;
                installation = system_installation;
            } else {
                dest_path = user_metadata_path;
                installation = user_installation;
            }
    
            if (installation == null) {
                return;
            }
    
            var dest_folder = File.new_for_path (dest_path);
            if (!dest_folder.query_exists ()) {
                try {
                    dest_folder.make_directory_with_parents ();
                } catch (Error e) {
                    critical ("Error while creating flatpak metadata dir: %s", e.message);
                    return;
                }
            }
    
            delete_folder_contents (dest_folder);
    
            for (int i = 0; i < remotes.length; i++) {
                unowned Flatpak.Remote remote = remotes[i];
    
                bool cache_refresh_needed = false;
    
                unowned string origin_name = remote.get_name ();
                debug ("Found remote: %s", origin_name);
    
                if (remote.get_disabled ()) {
                    debug ("%s is disabled, skipping.", origin_name);
                    continue;
                }
    
                var timestamp_file = remote.get_appstream_timestamp (null);
                if (!timestamp_file.query_exists ()) {
                    cache_refresh_needed = true;
                } else {
                    var age = get_file_age (timestamp_file);
                    debug ("Appstream age: %u", age);
                    if (age > MAX_APPSTREAM_AGE) {
                        cache_refresh_needed = true;
                    }
                }
    
                if (cache_refresh_needed) {
                    debug ("Updating remote");
                    bool success = false;
                    try {
                        success = installation.update_remote_sync (remote.get_name ());
                    } catch (Error e) {
                        warning ("Unable to update remote: %s", e.message);
                    }
                    debug ("Remote updated: %s", success.to_string ());
    
                    debug ("Updating appstream data");
                    success = false;
                    try {
                        success = installation.update_appstream_sync (remote.get_name (), null, null, cancellable);
                    } catch (Error e) {
                        warning ("Unable to update appstream: %s", e.message);
                    }
    
                    debug ("Appstream updated: %s", success.to_string ());
                }
    
                var metadata_location = remote.get_appstream_dir (null).get_path ();
                var metadata_folder_file = File.new_for_path (metadata_location);
    
                var metadata_path = Path.build_filename (metadata_location, "appstream.xml.gz");
                var metadata_file = File.new_for_path (metadata_path);
    
                if (metadata_file.query_exists ()) {
                    var dest_file = dest_folder.get_child (origin_name + ".xml.gz");
    
                    perform_xml_fixups (origin_name, metadata_file, dest_file);
    
                    var local_icons_path = dest_folder.get_child ("icons");
                    if (!local_icons_path.query_exists ()) {
                        try {
                            local_icons_path.make_directory ();
                        } catch (Error e) {
                            warning ("Error creating flatpak icons structure, icons may not display: %s", e.message);
                            continue;
                        }
                    }
    
                    var remote_icons_folder = metadata_folder_file.get_child ("icons");
                    if (!remote_icons_folder.query_exists ()) {
                        continue;
                    }
    
                    if (remote_icons_folder.get_child (origin_name).query_exists ()) {
                        local_icons_path = local_icons_path.get_child (origin_name);
                        try {
                            local_icons_path.make_symbolic_link (remote_icons_folder.get_child (origin_name).get_path ());
                        } catch (Error e) {
                            warning ("Error creating flatpak icons structure, icons may not display: %s", e.message);
                            continue;
                        }
                    } else {
                        local_icons_path = local_icons_path.get_child (origin_name);
                        try {
                            local_icons_path.make_symbolic_link (remote_icons_folder.get_path ());
                        } catch (Error e) {
                            warning ("Error creating flatpak icons structure, icons may not display: %s", e.message);
                            continue;
                        }
                    }
                } else {
                    continue;
                }
            }
        }

        public async uint64 get_download_size (Package package, Cancellable? cancellable, bool is_update = false) throws GLib.Error {
            var bundle = package.component.get_bundle (AppStream.BundleKind.FLATPAK);
            if (bundle == null) {
                return 0;
            }
    
            unowned var fp_package = package as FlatpakPackage;
            if (fp_package == null) {
                return 0;
            }
    
            bool system = fp_package.installation == system_installation;
    
            var id = generate_package_list_key (system, package.component.get_origin (), bundle.get_id ());
            return yield get_download_size_by_id (id, cancellable, is_update, package);
        }
    
        public async uint64 get_download_size_by_id (string id, Cancellable? cancellable, bool is_update = false, Package? package = null) throws GLib.Error {
            bool system;
            string origin, bundle_id;
            var split_success = get_package_list_key_parts (id, out system, out origin, out bundle_id);
            if (!split_success) {
                return 0;
            }
    
            unowned Flatpak.Installation? installation = null;
            if (system) {
                installation = system_installation;
            } else {
                installation = user_installation;
            }
    
            if (installation == null) {
                return 0;
            }
    
            uint64 download_size = 0;
    
            var added_remotes = new Gee.ArrayList<string> ();
    
            try {
                var transaction = new Flatpak.Transaction.for_installation (installation, cancellable);
                transaction.add_default_dependency_sources ();
                if (is_update) {
                    transaction.add_update (bundle_id, null, null);
                } else {
                    transaction.add_install (origin, bundle_id, null);
                }
    
                transaction.add_new_remote.connect ((reason, from_id, remote_name, url) => {
                    if (reason == Flatpak.TransactionRemoteReason.RUNTIME_DEPS) {
                        added_remotes.add (url);
                        return true;
                    }
    
                    return false;
                });
    
                transaction.ready.connect (() => {
                    var operations = transaction.get_operations ();
                    operations.foreach ((entry) => {
    
                        download_size += entry.get_download_size ();
                    });
    
                    // Do not allow the install to start, this is a dry run
                    return false;
                });
    
                transaction.run (cancellable);
    
                // Cleanup any remotes we had to add while testing the transaction
                installation.list_remotes ().foreach ((remote) => {
                    if (remote.get_url () in added_remotes) {
                        try {
                            installation.remove_remote (remote.get_name ());
                        } catch (Error e) {
                            warning ("Error while removing dry run remote: %s", e.message);
                        }
                    }
                });
            } catch (Error e) {
                if (!(e is Flatpak.Error.ABORTED)) {
                    throw e;
                }
            }
    
            return download_size;
        }

        public async PackageDetails get_package_details (Package package) throws GLib.Error {
            var details = new PackageDetails ();
            details.name = package.component.get_name ();
            details.description = package.component.get_description ();
            details.summary = package.component.get_summary ();
    
            var newest_version = package.get_newest_release ();
            if (newest_version != null) {
                details.version = newest_version.get_version ();
            }
    
            return details;
        }

        private void refresh_cache_internal (Job job) {
            unowned var args = (RefreshCacheArgs)job.args;
            unowned var cancellable = args.cancellable;
    
            if (user_installation == null && system_installation == null) {
                critical ("Error refreshing flatpak cache due to no installation");
                return;
            }
    
            GLib.GenericArray<weak Flatpak.Remote> remotes = null;
    
            if (user_installation != null) {
                try {
                    user_installation.drop_caches ();
                    remotes = user_installation.list_remotes ();
                    preprocess_metadata (false, remotes, cancellable);
                } catch (Error e) {
                    critical ("Error getting user flatpak remotes: %s", e.message);
                }
            }
    
            if (system_installation != null) {
                try {
                    system_installation.drop_caches ();
                    remotes = system_installation.list_remotes ();
                    preprocess_metadata (true, remotes, cancellable);
                } catch (Error e) {
                    warning ("Error getting system flatpak remotes: %s", e.message);
                }
            }
    
            reload_appstream_pool ();
            //  TODO cache flush
            //  BackendAggregator.get_default ().cache_flush_needed ();
    
            job.result = Value (typeof (bool));
            job.result.set_boolean (true);
            job.results_ready ();
        }

        public async bool refresh_cache (Cancellable? cancellable) throws GLib.Error {
            var job_args = new RefreshCacheArgs ();
            job_args.cancellable = cancellable;

            var job = yield launch_job (Job.Type.REFRESH_CACHE, job_args);
            if (job.error != null) {
                throw job.error;
            }

            return job.result.get_boolean ();
        }

        private string generate_package_list_key (bool system, string origin, string bundle_id) {
            unowned string installation = system ? "system" : "user";
            return "%s/%s/%s".printf (installation, origin, bundle_id);
        }

        public bool get_package_list_key_parts (string key, out bool? system, out string? origin, out string? bundle_id) {
            system = null;
            origin = null;
            bundle_id = null;
    
            string[] parts = key.split ("/", 3);
            if (parts.length != 3) {
                return false;
            }
    
            system = parts[0] == "system";
            origin = parts[1];
            bundle_id = parts[2];
    
            return true;
        }

        public async Gee.ArrayList<string> get_updates (Cancellable? cancellable = null) {
            var updatable_ids = new Gee.ArrayList<string> ();
    
            if (user_installation == null && system_installation == null) {
                critical ("Unable to get flatpak installation when checking for updates");
                return updatable_ids;
            }
    
            GLib.GenericArray<weak Flatpak.InstalledRef> update_refs;
    
            if (user_installation != null) {
                try {
                    update_refs = user_installation.list_installed_refs_for_update (cancellable);
                    for (int i = 0; i < update_refs.length; i++) {
                        unowned Flatpak.InstalledRef updatable_ref = update_refs[i];
                        updatable_ids.add (generate_package_list_key (false, updatable_ref.origin, updatable_ref.format_ref ()));
                    }
                } catch (Error e) {
                    critical ("Unable to get list of updatable flatpaks: %s", e.message);
                    return updatable_ids;
                }
            }
    
            if (system_installation != null) {
                try {
                    update_refs = system_installation.list_installed_refs_for_update (cancellable);
    
                    for (int i = 0; i < update_refs.length; i++) {
                        unowned Flatpak.InstalledRef updatable_ref = update_refs[i];
                        updatable_ids.add (generate_package_list_key (true, updatable_ref.origin, updatable_ref.format_ref ()));
                    }
                } catch (Error e) {
                    critical ("Unable to get list of updatable flatpaks: %s", e.message);
                    return updatable_ids;
                }
            }
    
            return updatable_ids;
        }

        public Package? lookup_package_by_id (string id) {
            return package_list[id];
        }

        // Preferences work
        public Gee.ArrayList<Flatpak.Remote> get_remotes (bool system, Cancellable cancellable) {
            var remotes_list = new Gee.ArrayList<Flatpak.Remote> ();
            unowned Flatpak.Installation? installation = null;

            if (system) {
                installation = system_installation;
            } else {
                installation = user_installation;
            }

            try {
                installation.list_remotes (cancellable).foreach ((remote) => {
                    remotes_list.add (remote);
                });
            } catch (Error e) {
                warning ("Error getting remotes: %s", e.message);
            }

            return remotes_list;
        }

        public bool modify_remote (Flatpak.Remote remote, Cancellable cancellable) {
            unowned Flatpak.Installation? installation = null;

            var system_remotes = get_remotes (true, cancellable);
            var user_remotes = get_remotes (false, cancellable);

            foreach (var sremote in system_remotes) {
                if (sremote.get_name () == remote.get_name ()) {
                    installation = system_installation;
                    try {
                        return installation.modify_remote (remote, cancellable);
                    } catch (Error e) {
                        warning ("Error saving remote state: %s", e.message);
                    }
                }
            }

            foreach (var uremote in user_remotes) {
                if (uremote.get_name () == remote.get_name ()) {
                    installation = user_installation;
                    try {
                        return installation.modify_remote (remote, cancellable);
                    } catch (Error e) {
                        warning ("Error saving remote state: %s", e.message);
                    }
                }
            }

            warning ("Remote not found in installation");
            return false;
        }
    
        private static GLib.Once<FlatpakBackend> instance;
        public static unowned FlatpakBackend get_default () {
            return instance.once (() => { return new FlatpakBackend (); });
        }
    }
}
