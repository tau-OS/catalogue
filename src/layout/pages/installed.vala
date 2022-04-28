/* layout/pages/installed.vala
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

namespace Catalogue {
    [GtkTemplate (ui = "/co/tauos/Catalogue/installed.ui")]
    public class WindowInstalled : Adw.Bin {
        [GtkChild]
        private unowned Gtk.ListBox in_progress_listbox;
        [GtkChild]
        private unowned Gtk.ListBox apps_listbox;

        private Cancellable refresh_cancellable;

        private AsyncMutex refresh_mutex = new AsyncMutex ();

        public WindowInstalled () {
            Object ();

            refresh_cancellable = new Cancellable ();

            in_progress_listbox.append (new Adw.ActionRow ());

            // wish there was a signal on row add
            in_progress_listbox.set_visible (true);

            this.realize.connect (() => {
                get_apps.begin ();
            });

            apps_listbox.set_sort_func ((row1, row2) => {
                return ((Catalogue.InstalledRow) row1).title.collate (((Catalogue.InstalledRow) row2).title);
            });
        }

        public async void get_apps () {
            refresh_cancellable.cancel ();

            yield refresh_mutex.lock ();

            refresh_cancellable.reset ();

            unowned Core.Client client = Core.Client.get_default ();

            var installed_apps = yield client.get_installed_applications (refresh_cancellable);

            if (!refresh_cancellable.is_cancelled ()) {
                foreach (var package in installed_apps) {
                    apps_listbox.append (new Catalogue.InstalledRow (package, "Uninstall"));
                }
            }

            refresh_mutex.unlock ();
        }
    }
}
