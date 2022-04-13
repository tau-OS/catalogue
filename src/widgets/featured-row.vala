/* widgets/featured-row.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/featured-row.ui")]
    public class FeaturedRow : Adw.Bin {
        [GtkChild]
        private unowned Adw.PreferencesGroup row_container;
        [GtkChild]
        private unowned Gtk.FlowBox row_box;

        public signal void explore_leaflet_open ();

        // TODO pass GtkWidgets for the flowbox
        public FeaturedRow (string title) {
            Object ();

            row_container.set_title (title);

            for (var i = 0; i < 10; i++) {
                var app_tile = new Catalogue.AppTile ("UwU", "This is a test app", "$1.99");

                app_tile.explore_leaflet_open.connect (() => explore_leaflet_open ());

                // this  needs to be updated lol
                row_box.append (app_tile);
            }
        }
    }
}
