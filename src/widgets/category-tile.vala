/* widgets/category-tile.vala
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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/category-tile.ui")]
    public class CategoryTile : Gtk.Button {
        [GtkChild]
        private unowned Gtk.Label category_label;
        [GtkChild]
        private unowned Gtk.Image category_icon;
        
        public CategoryTile (string label, string icon) {
            Object ();

            category_label.set_label (label);
            category_icon.set_from_icon_name (icon);
        }
    }
}
