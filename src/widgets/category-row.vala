/* widgets/category-row.vala
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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/category-row.ui")]
    public class CategoryRow : He.Bin {
        [GtkChild]
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned Gtk.FlowBox loading_row_box;
        [GtkChild]
        private unowned Gtk.FlowBox row_box;

        private void reset () {
            var widget_list = new Utils ().get_all_widgets_in_child (row_box);

            foreach (var widget in widget_list) {
                row_box.remove (widget);
            }
        }

        private async void fill_row (AppStream.Category category) {
            unowned var client = Core.Client.get_default ();
            Gee.Collection<Catalogue.AppTile> pkgs = new Gee.ArrayList<Catalogue.AppTile> ();

            foreach (var package in client.get_applications_for_category (category)) {
                var package_row = new Catalogue.AppTile (package);

                pkgs.add (package_row);
            }

            reset ();

            if (!pkgs.is_empty) {
                foreach (var package in pkgs) {
                    row_box.append (package);
                }

                stack.set_visible_child_name ("content");
            }

            return;
        }

        public CategoryRow (AppStream.Category? category) {
            Object ();

            for (var i = 0; i < 6; i++){
                loading_row_box.append (new Catalogue.SkeletonTile ());
            }

            stack.set_visible_child_name ("loading");

            this.realize.connect (() => {
                if (category != null) {
                    ThreadService.run_in_thread.begin<void> (() => { fill_row.begin (category); });
                }
            });
            
            row_box.child_activated.connect ((child) => {
                ((AppTile) child.get_child ()).click ();
            });
        }
    }
}
