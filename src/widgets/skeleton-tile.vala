/* widgets/skeleton-tile.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/skeleton-tile.ui")]
    public class SkeletonTile : Gtk.Button {
        [GtkChild]
        private unowned Gtk.Label title_label;
        [GtkChild]
        private unowned Gtk.Label description_label;
        [GtkChild]
        private unowned Gtk.Label price_label;
        
        public SkeletonTile () {
            Object ();

            title_label.get_style_context ().add_class ("skeleton");
            title_label.set_label ("Loading...");
            description_label.get_style_context ().add_class ("skeleton");
            description_label.set_label (".Loading..");
            price_label.get_style_context ().add_class ("skeleton");
            price_label.set_label ("...");

            this.sensitive = false;
        }
    }
}
