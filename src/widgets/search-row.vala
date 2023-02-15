/* widgets/search-row.vala
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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/search-row.ui")]
    public class SearchRow : Gtk.Box {
        [GtkChild]
        private unowned Gtk.Button info_button;
        [GtkChild]
        private unowned He.MiniContentBlock lbrow;

        private Core.Package app;

        public SearchRow (Core.Package package) {
            Object ();

            app = package;

            lbrow.title = (package.get_name ());
            lbrow.subtitle = (package.get_summary ());

            lbrow.gicon = (package.get_icon (64, 64));

            info_button.clicked.connect (() => {
                Application.main_window.view_package_details (package);
            });
        }

        public string get_app_name () {
            return app.get_name ();
        }
    }
}
