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
    [GtkTemplate (ui = "/co/tauos/Catalogue/search-row.ui")]
    public class SearchRow : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Label app_name;
        [GtkChild]
        private unowned Gtk.Label app_description;
        [GtkChild]
        private unowned Gtk.Image image;
        [GtkChild]
        private unowned Gtk.Button info_button;

        private Core.Package app;

        public SearchRow (Core.Package package) {
            Object ();

            app = package;

            app_name.set_label (package.get_name ());
            app_description.set_label (package.get_summary ());

            image.set_from_gicon (package.get_icon (64, 64));

            info_button.clicked.connect (() => {
                Application.main_window.view_package_details (package);
            });

            this.realize.connect (() => {
                // Set the parent element to be unselectable lol
                ((Gtk.ListBoxRow) this.get_parent ()).selectable = false;
            });
        }

        public string get_app_name () {
            return app.get_name ();
        }
    }
}
