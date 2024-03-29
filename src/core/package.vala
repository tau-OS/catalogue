/* core/package.vala
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
    public class PackageDetails : Object {
        public string? name { get; set; }
        public string? description { get; set; }
        public string? summary { get; set; }
        public string? version { get; set; }
    }

    public class Package : Object {
        public signal void changing (bool is_changing);
        public signal void info_changed (ChangeInformation.Status status);

        public enum State {
            UPDATE_AVAILABLE,
            NOT_INSTALLED,
            INSTALLED,
            INSTALLING,
            UPDATING,
            UNINSTALLING
        }

        public const string RUNTIME_UPDATES_ID = "xxx-runtime-updates";

        public AppStream.Component component { get; protected set; }
        public ChangeInformation change_information { public get; private set; }
        public GLib.Cancellable action_cancellable { public get; private set; }
        public State state { public get; private set; default = State.NOT_INSTALLED; }

        private string? color_primary = null;

        public double progress {
            get {
                return change_information.progress;
            }
        }

        // Get if package is installed
        private bool _installed = false;
        public bool installed {
            get {
                if (component.get_id () == RUNTIME_UPDATES_ID) {
                    return true;
                }
                
                return _installed;
            }
        }

        public void mark_installed () {
            _installed = true;
            update_state ();
        }

        public void clear_installed () {
            _installed = false;
            update_state ();
        }

        public bool update_available {
            get {
                return state == State.UPDATE_AVAILABLE;
            }
        }

        public bool is_runtime_updates {
            get {
                return component.id == RUNTIME_UPDATES_ID;
            }
        }

        // Get the package author/developer
        private string? _author = null;
        public string author {
            get {
                if (_author != null) {
                    return _author;
                }

                _author = component.developer_name;

                if (_author == null) {
                    var project_group = component.project_group;

                    if (project_group != null) {
                        _author = project_group;
                    }
                }

                return _author;
            }
        }

        private string? _author_title = null;
        public string author_title {
            get {
                if (_author_title != null) {
                    return _author_title;
                }

                _author_title = author;
                if (_author_title == null) {
                    _author_title = _("%s Developers").printf (get_name ());
                }

                return _author_title;
            }
        }

        public bool is_plugin {
            get {
                return component.get_kind () == AppStream.ComponentKind.ADDON;
            }
        }

        public string origin_description {
            owned get {
                var fp_package = this as FlatpakPackage;
                unowned string origin = component.get_origin ();

                // If the package is a system package
                if (fp_package != null && fp_package.installation == FlatpakBackend.system_installation) {
                    return _("%s (system-wide)").printf (origin);
                } else if (origin == "catalogue") {
                    return _("Catalogue");
                } else if (origin == "catalogue-unstable") {
                    return ("Catalogue (Unstable)");
                } else if (origin == "flathub") {
                    return ("Flathub (non-curated)");
                }
    
                return _("Unknown Origin (non-curated)");
            }
        }

        public string? description = null;
        private string? summary = null;
        private string? _latest_version = null;
        public string? latest_version {
            private get { return _latest_version; }
            internal set { _latest_version = convert_version (value); }
        }

        private PackageDetails? backend_details = null;

        construct {
            change_information = new ChangeInformation ();
            change_information.status_changed.connect (() => info_changed (change_information.status));
        
            action_cancellable = new GLib.Cancellable ();
        }

        public Package (AppStream.Component component) {
            Object (component: component);
        }
    
        public void replace_component (AppStream.Component component) {
            name = null;
            description = null;
            summary = null;
            _author = null;
            _author_title = null;
            _latest_version = null;
            backend_details = null;
    
            this.component = component;
        }

        public void update_state () {
            State new_state;
    
            if (installed) {
                if (change_information.has_changes ()) {
                    new_state = State.UPDATE_AVAILABLE;
                } else {
                    new_state = State.INSTALLED;
                }    
            } else {
                new_state = State.NOT_INSTALLED;
            }
    
            // Only trigger a notify if the state has changed, quite a lot of things listen to this
            if (state != new_state) {
                state = new_state;
            }
        }

        public async bool update (bool is_grouped = false) throws GLib.Error {
            if (state != State.UPDATE_AVAILABLE) {
                return false;
            }

            var success = yield perform_operation (State.UPDATING, State.INSTALLED, State.UPDATE_AVAILABLE);
            if (success && !is_grouped) {
                if (!is_grouped) {
                    string title = !is_grouped ? "Package %s Updated".printf (this.get_name ()) : "Packages Updated";
                    var application = GLib.Application.get_default ();
                    var notification = new Notification (title);
                    notification.set_icon (new ThemedIcon ("emblem-ok-symbolic"));

                    application.send_notification ("catalogue.successful_install", notification);
                }
                debug ("Package %s Updated", this.get_name ());
            }

            return success;
        }

        public async bool install () throws GLib.Error {
            if (state != State.NOT_INSTALLED) {
                return false;
            }

            var success = yield perform_operation (State.INSTALLING, State.INSTALLED, State.NOT_INSTALLED);
            if (success) {
                var client = Client.get_default ();
                client.installed_apps_changed ();

                string title = "Package %s Installed".printf (this.get_name ());
                var application = GLib.Application.get_default ();
                var notification = new Notification (title);
                notification.set_icon (new ThemedIcon ("emblem-ok-symbolic"));

                application.send_notification ("catalogue.successful_install", notification);
                debug ("Package %s Installed", this.get_name ());
            }

            return success;
        }

        public async bool uninstall () throws GLib.Error {
            if (state != State.INSTALLED && state != State.UPDATE_AVAILABLE) {
                return false;
            }

            var success = yield perform_operation (State.UNINSTALLING, State.NOT_INSTALLED, state);
            if (success) {
                var client = Client.get_default ();
                client.installed_apps_changed ();

                string title = "Package %s Removed".printf (this.get_name ());
                var application = GLib.Application.get_default ();
                var notification = new Notification (title);
                notification.set_icon (new ThemedIcon ("emblem-ok-symbolic"));

                application.send_notification ("catalogue.successful_install", notification);
                debug ("Package %s Removed", this.get_name ());
            }

            return success;
        }

        private async bool perform_operation (State performing, State after_success, State after_fail) throws GLib.Error {
            bool success = false;
            
            changing (true);

            action_cancellable.reset ();
            change_information.start ();
            state = performing;

            try {
                success = yield perform_package_operation ();
            } catch (GLib.Error e) {
                warning ("Operation failed for package %s - %s", get_name (), e.message);
                throw e;
            } finally {
                changing (false);
                if (success) {
                    change_information.complete ();
                    state = after_success;
                } else {
                    state = after_fail;
                    change_information.cancel ();
                }
            }

            return success;
        }

        private async bool perform_package_operation () throws GLib.Error {
            switch (state) {
                case State.UPDATING:
                    var success = yield FlatpakBackend.get_default ().update_package (this, change_information, action_cancellable);
                    if (success) {
                        change_information.clear_update_info ();
                        update_state ();
                    }

                    return success;
                case State.INSTALLING:
                    var success = yield FlatpakBackend.get_default ().install_package (this, change_information, action_cancellable);
                    _installed = success;
                    update_state ();
                    return success;
                case State.UNINSTALLING:
                    var success = yield FlatpakBackend.get_default ().uninstall_package (this, change_information, action_cancellable);
                    _installed = !success;
                    update_state ();
                    return success;
                default:
                    return false;
            }
        }
    
        private string? name = null;
        public string? get_name () {
            if (name != null) {
                return name;
            }
    
            name = component.get_name ();
            if (name == null) {
                if (backend_details == null) {
                    populate_backend_details_sync ();
                }
    
                name = backend_details.name;
            }
    
            name = Core.unescape_markup (name);
    
            return name;
        }
    
        public string? get_description () {
            if (description == null) {
                description = component.get_description ();
    
                if (description == null) {
                    if (backend_details == null) {
                        populate_backend_details_sync ();
                    }
    
                    description = backend_details.description;
                }
    
                if (description == null) {
                    return null;
                }
    
                try {
                    var space_regex = new Regex ("\\s+");
                    description = space_regex.replace (description, description.length, 0, " ");
                } catch (Error e) {
                   warning ("Failed to condense spaces: %s", e.message);
                }
    
                try {
                    description = AppStream.markup_convert_simple (description);
                } catch (Error e) {
                    warning ("Failed to convert description to markup: %s", e.message);
                }
            }
    
            return description;
        }
    
        public string? get_summary () {
            if (summary != null) {
                return summary;
            }
    
            summary = component.get_summary ();
            if (summary == null) {
                if (backend_details == null) {
                    populate_backend_details_sync ();
                }
    
                summary = backend_details.summary;
            }
    
            return summary;
        }
    
        public GLib.Icon get_icon (uint size, uint scale_factor) {
            GLib.Icon? icon = null;
            uint current_size = 0;
            uint current_scale = 0;
            uint pixel_size = size * scale_factor;
    
            weak GenericArray<AppStream.Icon> icons = component.get_icons ();
            for (int i = 0; i < icons.length; i++) {
                weak AppStream.Icon _icon = icons[i];
                switch (_icon.get_kind ()) {
                    case AppStream.IconKind.STOCK:
                        unowned string icon_name = _icon.get_name ();
                        if (Gtk.IconTheme.get_for_display (Gdk.Display.get_default ()).has_icon (icon_name)) {
                            return new ThemedIcon (icon_name);
                        }
    
                        break;
                    case AppStream.IconKind.CACHED:
                    case AppStream.IconKind.LOCAL:
                        var icon_scale = _icon.get_scale ();
                        var icon_width = _icon.get_width () * icon_scale;
                        bool is_bigger = (icon_width > current_size && current_size < pixel_size);
                        bool has_better_dpi = (icon_width == current_size && current_scale < icon_scale && scale_factor <= icon_scale);
                        if (is_bigger || has_better_dpi) {
                            var file = File.new_for_path (_icon.get_filename ());
                            icon = new FileIcon (file);
                            current_size = icon_width;
                            current_scale = icon_scale;
                        }
    
                        break;
                    case AppStream.IconKind.REMOTE:
                        var icon_scale = _icon.get_scale ();
                        var icon_width = _icon.get_width () * icon_scale;
                        bool is_bigger = (icon_width > current_size && current_size < pixel_size);
                        bool has_better_dpi = (icon_width == current_size && current_scale < icon_scale && scale_factor <= icon_scale);
                        if (is_bigger || has_better_dpi) {
                            var file = File.new_for_uri (_icon.get_url ());
                            icon = new FileIcon (file);
                            current_size = icon_width;
                            current_scale = icon_scale;
                        }
    
                        break;
                    case AppStream.IconKind.UNKNOWN:
                        icon = new ThemedIcon ("application-default-icon");
                        break;
                }
            }
    
            if (icon == null) {
                icon = new ThemedIcon ("application-default-icon");
            }
    
            return icon;
        }
    
        public string? get_version () {
            if (latest_version != null) {
                return latest_version;
            }
    
            if (backend_details == null) {
                populate_backend_details_sync ();
            }
    
            if (backend_details.version != null) {
                latest_version = backend_details.version;
            }
    
            return latest_version;
        }
    
        private string convert_version (string version) {
            string returned = version;
            returned = returned.split ("+", 2)[0];
            returned = returned.split ("-", 2)[0];
            returned = returned.split ("~", 2)[0];
            if (":" in returned) {
                returned = returned.split (":", 2)[1];
            }
    
            return returned;
        }

        public string? get_color_primary () {
            if (color_primary != null) {
                return color_primary;
            } else {
                var branding = component.get_branding ();
                if (branding != null) {
                    color_primary = branding.get_color (AppStream.ColorKind.PRIMARY, AppStream.ColorSchemeKind.UNKNOWN);
                }
    
                if (color_primary == null) {
                    if (component.get_custom_value ("x-appcenter-color-primary") != null) {
                        color_primary = component.get_custom_value ("x-appcenter-color-primary");
                    } else {
                        if (component.get_custom_value ("GnomeSoftware::key-colors") != null) {
                            color_primary = component.get_custom_value ("GnomeSoftware::key-colors").replace ("[(", "rgb(").replace ("]", ";");
                        } else {
                            color_primary = "#f0f0f0";
                        }
                    }
                }
    
                return color_primary;
            }
        }

        public Gee.ArrayList<AppStream.Release> get_newest_releases (int min_releases, int max_releases) {
            var list = new Gee.ArrayList<AppStream.Release> ();
    
            var releases = component.get_releases ();
            uint index = 0;
            while (index < releases.length) {
                if (releases[index].get_version () == null) {
                    releases.remove_index (index);
                    if (index >= releases.length) {
                        break;
                    }
    
                    continue;
                }
    
                index++;
            }
    
            if (releases.length < min_releases) {
                return list;
            }
    
            releases.sort_with_data ((a, b) => {
                return b.vercmp (a);
            });
    
            string installed_version = get_version ();
    
            int start_index = 0;
            int end_index = min_releases;
    
            if (installed) {
                for (int i = 0; i < releases.length; i++) {
                    var release = releases.@get (i);
                    unowned string release_version = release.get_version ();
                    if (release_version == null) {
                        continue;
                    }
    
                    if (AppStream.utils_compare_versions (release_version, installed_version) == 0) {
                        end_index = i.clamp (min_releases, max_releases);
                        break;
                    }
                }
            }
    
            for (int j = start_index; j < end_index; j++) {
                list.add (releases.get (j));
            }
    
            return list;
        }

        public AppStream.Release? get_newest_release () {
            var releases = component.get_releases ();
            releases.sort_with_data ((a, b) => {
                if (a.get_version () == null || b.get_version () == null) {
                    if (a.get_version () != null) {
                        return -1;
                    } else if (b.get_version () != null) {
                        return 1;
                    } else {
                        return 0;
                    }
                }
    
                return b.vercmp (a);
            });
    
            if (releases.length > 0) {
                return releases[0];
            }
    
            return null;
        }

        public async uint64 get_installed_size () {
            if (state != State.INSTALLED) {
                return 0;
            } else {
                uint64 size = 0;
                try {
                    size = yield FlatpakBackend.get_default ().get_installed_size (this, null);
                } catch (Error e) {
                    warning ("Error getting installed size: %s", e.message);
                }

                return size;
            }
        }

        public async uint64 get_download_size_with_deps () {
            uint64 size = 0;
            try {
                size = yield FlatpakBackend.get_default ().get_download_size (this, null);
            } catch (Error e) {
                warning ("Error getting download size: %s", e.message);
            }

            return size;
        }

        private void populate_backend_details_sync () {    
            if (component.id == RUNTIME_UPDATES_ID) {
                backend_details = new PackageDetails ();
                return;
            }

            var loop = new MainLoop ();
            PackageDetails? result = null;
            FlatpakBackend.get_default ().get_package_details.begin (this, (obj, res) => {
                try {
                    result = FlatpakBackend.get_default ().get_package_details.end (res);
                } catch (Error e) {
                    warning (e.message);
                } finally {
                    loop.quit ();
                }
            });
    
            loop.run ();
            backend_details = result;
            if (backend_details == null) {
                backend_details = new PackageDetails ();
            }
        }
    }
}
