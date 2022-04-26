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

namespace Core {
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

        private Gee.HashMap<string, Package> package_list;
        private AppStream.Pool user_appstream_pool;
        private AppStream.Pool system_appstream_pool;

        private string user_metadata_path;
        private string system_metadata_path;

        public static Flatpak.Installation? user_installation { get; private set; }
        public static Flatpak.Installation? system_installation { get; private set; }

        construct {
            user_appstream_pool = new AppStream.Pool ();
            user_appstream_pool.set_flags (AppStream.PoolFlags.LOAD_OS_COLLECTION);

            system_appstream_pool = new AppStream.Pool ();
            system_appstream_pool.set_flags (AppStream.PoolFlags.LOAD_OS_COLLECTION);

            user_metadata_path = Path.build_filename (
                Environment.get_user_cache_dir (),
                "catalogue",
                "flatpak-metadata",
                "user"
            );
    
            system_metadata_path = Path.build_filename (
                Environment.get_user_cache_dir (),
                "catalogue",
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

        public Package? get_package_for_component_id (string id) {
            var suffixed_id = id + ".desktop";
            foreach (var package in package_list.values) {
                if (package.component.id == id) {
                    return package;
                } else if (package.component.id == suffixed_id) {
                    return package;
                }
            }
    
            return null;
        }

        private void reload_appstream_pool () {
            var new_package_list = new Gee.HashMap<string, Package> ();

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

                        new_package_list[key] = package;
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
                        var key = generate_package_list_key (false, comp.get_origin (), bundle.get_id ());
                        var package = package_list[key];
                        if (package != null) {
                            package.replace_component (comp);
                        } else {
                            package = new FlatpakPackage (user_installation, comp);
                        }

                        new_package_list[key] = package;
                    }
                });
            }

            package_list = new_package_list;
        }

        private string generate_package_list_key (bool system, string origin, string bundle_id) {
            unowned string installation = system ? "system" : "user";
            return "%s/%s/%s".printf (installation, origin, bundle_id);
        }

        public Package? lookup_package_by_id (string id) {
            return package_list[id];
        }
    
        private static GLib.Once<FlatpakBackend> instance;
        public static unowned FlatpakBackend get_default () {
            return instance.once (() => { return new FlatpakBackend (); });
        }
    }
}
