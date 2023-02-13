/* dialog/version-history.vala
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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/Dialogs/version-history.ui")]
    public class VersionHistoryDialog : He.Window {
        [GtkChild]
        private unowned Gtk.ListBox list_box_version_history;

        public VersionHistoryDialog (Core.Package package) {
            Object ();

            var releases = package.component.get_releases ();

            foreach (var release in releases) {
                list_box_version_history.prepend (new Catalogue.AppVersionHistoryRow (release));
            }
        }
    }
}
