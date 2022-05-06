/* core/update_manager.vala
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
    public class UpdateManager : Object {
        public Package runtime_updates { public get; private set; }

        construct {
            // Used for apps that have no metadata
            var icon = new AppStream.Icon ();
            icon.set_name ("application-x-executable");
            icon.set_kind (AppStream.IconKind.STOCK);

            var updates_component = new AppStream.Component ();
            updates_component.id = Core.Package.RUNTIME_UPDATES_ID;
            updates_component.name = _("Runtime Updates");
            updates_component.summary = _("Updates to runtime components");
            updates_component.add_icon (icon);

            runtime_updates = new Core.Package (updates_component);
        }

        public async uint get_updates (Cancellable? cancellable = null) {
            var apps_with_updates = new Gee.TreeSet<Package> ();
            uint count = 0;

            // Clear all apps marked as updatable
            var installed_packages = yield FlatpakBackend.get_default ().get_installed_applications ();
            foreach (var package in installed_packages) {
                package.change_information.clear_update_info ();
                package.update_state ();
            }

            uint runtime_count = 0;
            string desc = "";

            unowned FlatpakBackend client = FlatpakBackend.get_default ();
            var updates = yield client.get_updates ();
            debug ("Flatpak reports %d updates", updates.size);

            // TODO add auto update support

            foreach (var update in updates) {
                var package = client.lookup_package_by_id (update);
                if (package != null) {
                    debug ("Added %s to app updates", update);
                    apps_with_updates.add (package);

                    count++;

                    package.change_information.updatable_packages.@set (client, update);
                    package.update_state ();
                    try {
                       package.change_information.size = yield client.get_download_size (package, null, true);
                    } catch (Error e) {
                        warning ("Unable to get flatpak download size: %s", e.message);
                    }
                } else {
                    debug ("Added %s to runtime updates", update);
                    string bundle_id;
                    var list = FlatpakBackend.get_default ().get_package_list_key_parts (update, null, null, out bundle_id);
                    if (!list) {
                        continue;
                    }

                    Flatpak.Ref @ref;
                    try {
                        @ref = Flatpak.Ref.parse (bundle_id);
                    } catch (Error e) {
                        warning ("Error parsing flatpak bundle ID: %s", e.message);
                        continue;
                    }

                    runtime_count++;

                    desc += Markup.printf_escaped (
                        " • %s\n\t%s\n",
                        @ref.get_name (),
                        _("Flatpak runtime")
                    );

                    uint64 dl_size = 0;
                    try {
                        dl_size = yield client.get_download_size_by_id (update, null, true);
                    } catch (Error e) {
                        warning ("Unable to get flatpak download size: %s", e.message);
                    }

                    runtime_updates.change_information.size += dl_size;
                    runtime_updates.change_information.updatable_packages.@set (client, update);
                }
            }

            if (runtime_count == 0) {
                debug ("No Runtime updates found");
                var latest_version = _("No components with updates");
                runtime_updates.latest_version = latest_version;
                runtime_updates.description = Markup.printf_escaped ("%s\n", latest_version);
            } else {
                debug ("%u Runtime updates found", runtime_count);
                var latest_version = ngettext ("%u component with updates", "%u components with updates", runtime_count).printf (runtime_count);
                runtime_updates.latest_version = latest_version;
                runtime_updates.description = "%s\n%s\n".printf (Markup.printf_escaped (_("%s:"), latest_version), desc);
            }
    
            debug ("%u app updates found", count);
            if (runtime_count > 0) {
                count += 1;
            }
            
            runtime_updates.update_state ();
            return count;
        }

        private static GLib.Once<UpdateManager> instance;
        public static unowned UpdateManager get_default () {
            return instance.once (() => { return new UpdateManager (); });
        }
    }
}
