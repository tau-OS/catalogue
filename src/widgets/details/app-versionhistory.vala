/* widgets/details/app-versionhistory.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/details/app-versionhistory.ui")]
    public class AppVersionHistory : Adw.Bin {
        [GtkChild]
        private unowned Gtk.ListBox list_box_version_history;
        [GtkChild]
        private unowned Gtk.ListBoxRow version_history_button;

        private Core.Package app;

        [GtkCallback]
        private void open_history_dialog (Gtk.ListBoxRow row) {
            if (row == version_history_button) {
                var win = ((Window)new Utils ().find_ancestor_of_type<Window>(this));
                var dialog = new Catalogue.VersionHistoryDialog (app);
                dialog.set_transient_for (win);
                dialog.present ();
            }
        }
            
        public AppVersionHistory (Core.Package package) {
            Object ();

            app = package;

            var releases = package.get_newest_releases (1, 5);

            foreach (var release in releases) {
                list_box_version_history.prepend (new Catalogue.AppVersionHistoryRow (release));
            }
        }
    }
}
 