/* utils.vala
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
    public class Utils {
        public Gtk.Widget[] get_all_widgets_in_child (Gtk.Widget parent) {
            Gtk.Widget[] widgets = {};
            var widget = parent.get_first_child ();
            Gtk.Widget? next = null;
            if (widget != null) {
                widgets += widget;
                while ((next = widget.get_next_sibling ()) != null) {
                    widget = next;
                    widgets += widget;
                }
            }
            return widgets;
        }
    }
}
