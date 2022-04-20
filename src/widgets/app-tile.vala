/* widgets/app-tile.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/app-tile.ui")]
    public class AppTile : Gtk.Button {
        [GtkChild]
        private unowned Gtk.Label title_label;
        [GtkChild]
        private unowned Gtk.Label description_label;
        [GtkChild]
        private unowned Gtk.Label price_label;
        
        public AppTile (string title, string description, string price) {
            Object ();

            title_label.set_label (title);
            description_label.set_label (description);
            price_label.set_label (price);

            this.clicked.connect (() => {
                Signals.get_default ().explore_leaflet_open ();
            });
        }
    }
}
