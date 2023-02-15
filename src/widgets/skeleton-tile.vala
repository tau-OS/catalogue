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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/skeleton-tile.ui")]
    public class SkeletonTile : He.MiniContentBlock {
        [GtkChild]
        private unowned Gtk.Label price_label;
        
        public SkeletonTile () {
            Object ();

            title = ("████████████");
            subtitle = ("████████████");
            price_label.set_label ("████");

            this.sensitive = false;
            this.get_style_context ().add_class ("skeleton");
        }
    }
}
