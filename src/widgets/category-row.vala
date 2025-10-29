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

        private AppStream.Category? category;
        private bool has_loaded = false;

        private void reset () {
            var widget_list = new Utils ().get_all_widgets_in_child (row_box);

            foreach (var widget in widget_list) {
                row_box.remove (widget);
            }
        }

        private async void fill_row () {
            if (category == null) {
                return;
            }

            unowned var client = Core.Client.get_default ();
            
            // Get packages in background thread
            var packages = client.get_applications_for_category (category);

            // Update UI in main thread with packages
            Idle.add (() => {
                reset ();

                if (packages != null && !packages.is_empty) {
                    // Switch to content immediately and add items progressively
                    stack.set_visible_child_name ("content");
                    
                    // Create widgets on main thread but do it incrementally
                    var pkg_list = new Gee.ArrayList<Core.Package> ();
                    pkg_list.add_all (packages);
                    
                    // Process in chunks to keep UI responsive
                    int index = 0;
                    GLib.Idle.add (() => {
                        if (index >= pkg_list.size) {
                            has_loaded = true;
                            return false;
                        }
                        
                        // Add 6 items at a time (the visible amount on no scroll)
                        int chunk_end = int.min (index + 6, pkg_list.size);
                        for (int i = index; i < chunk_end; i++) {
                            var package_row = new Catalogue.AppTile (pkg_list[i]);
                            row_box.append (package_row);
                        }
                        index = chunk_end;
                        
                        return true; // Continue until done
                    }, GLib.Priority.DEFAULT_IDLE);
                } else {
                    stack.set_visible_child_name ("loading");
                    has_loaded = true;
                }

                return false;
            });
        }

        public void load_if_needed () {
            if (!has_loaded) {
                stack.set_visible_child_name ("loading");
                ThreadService.run_in_thread.begin<void> (() => { fill_row.begin (); });
            }
        }

        public CategoryRow (AppStream.Category? category) {
            Object ();

            this.category = category;

            for (var i = 0; i < 12; i++){
                loading_row_box.append (new Catalogue.SkeletonTile ());
            }

            // Start with content view (empty), not loading view
            stack.set_visible_child_name ("content");

            unowned var client = Core.Client.get_default ();
            
            client.cache_update_finished.connect (() => {
                if (has_loaded && category != null) {
                    ThreadService.run_in_thread.begin<void> (() => { fill_row.begin (); });
                }
            });
            
            row_box.child_activated.connect ((child) => {
                ((AppTile) child.get_child ()).click ();
            });
        }
    }
}
