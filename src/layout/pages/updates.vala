/* layout/pages/updates.vala
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

// TODO automatically handle refreshing updates lol
namespace Catalogue {
    [GtkTemplate (ui = "/co/tauos/Catalogue/updates.ui")]
    public class WindowUpdates : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned Gtk.ListBox listbox;

        private Cancellable refresh_cancellable;

        public WindowUpdates () {
            Object ();

            refresh_cancellable = new Cancellable ();

            this.realize.connect (() => {
                get_apps.begin ();
            });
        }

        public async void get_apps () {
            refresh_cancellable.cancel ();

            refresh_cancellable.reset ();

            unowned Core.Client client = Core.Client.get_default ();
            yield client.refresh_updates ();

            var installed_apps = yield client.get_installed_applications (refresh_cancellable);

            if (!refresh_cancellable.is_cancelled ()) {
                foreach (var package in installed_apps) {
                    var needs_update = package.state == Core.Package.State.UPDATE_AVAILABLE;

                    if (needs_update) {
                        stack.set_visible_child_name ("updates_available");
                        listbox.append (new Catalogue.InstalledRow (package));
                    }
                }
                
                // Handle runtime updates package
                var runtime_updates = Core.UpdateManager.get_default ().runtime_updates;
                if (runtime_updates.state ==Core.Package.State.UPDATE_AVAILABLE) {
                    listbox.append (new Catalogue.InstalledRow (runtime_updates));
                }
            }
        }
    }
}
