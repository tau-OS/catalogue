/* layout/pages/explore.vala
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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/explore.ui")]
    public class WindowExplore : Gtk.Box {
        [GtkChild]
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned Gtk.FlowBox featured_flowbox;
        [GtkChild]
        private unowned Catalogue.FeaturedRow new_updated;
        [GtkChild]
        private unowned Gtk.Box accessories_box;
        [GtkChild]
        private unowned Gtk.Box internet_box;
        [GtkChild]
        private unowned Gtk.Box develop_box;
        [GtkChild]
        private unowned Gtk.Box games_box;
        [GtkChild]
        private unowned Gtk.Box create_box;
        [GtkChild]
        private unowned Gtk.Box work_box;

        public AppStream.Category? active_category;

        public AppStream.Category? get_active_category () {
            if (active_category != null) {
                return active_category;
            } else {
                return null;
            }
        }

        public Gtk.Stack get_stack () {
            return stack;
        }

        public void reset_to_featured () {
            if (stack.get_visible_child_name () != "featured") {
                active_category = null;
                stack.set_visible_child_name ("featured");
                Application.main_window.hide_main_back_button ();
            }
        }

        public WindowExplore () {
            Object ();
        }

        construct {            
            var categories = new Catalogue.Categories ().get_default ();

            var categories_list = new AppStream.Category[] {};
            categories_list += categories.accessories;
            categories_list += categories.internet; 
            categories_list += categories.develop;
            categories_list += categories.games;
            categories_list += categories.create;
            categories_list += categories.work;

            // Create category rows but don't load them yet
            var accessories_row = new Catalogue.CategoryRow (categories.accessories);
            var internet_row = new Catalogue.CategoryRow (categories.internet);
            var develop_row = new Catalogue.CategoryRow (categories.develop);
            var games_row = new Catalogue.CategoryRow (categories.games);
            var create_row = new Catalogue.CategoryRow (categories.create);
            var work_row = new Catalogue.CategoryRow (categories.work);

            // Map category names to their rows for lazy loading
            var category_rows = new Gee.HashMap<string, Catalogue.CategoryRow> ();
            category_rows["accessories"] = accessories_row;
            category_rows["internet"] = internet_row;
            category_rows["develop"] = develop_row;
            category_rows["games"] = games_row;
            category_rows["create"] = create_row;
            category_rows["work"] = work_row;

            foreach (var entry in categories_list) {
                var name = entry.get_name ();

                // + "-symbolic" needed because the icons shouldn't be full-color here.
                var tile = new Catalogue.CategoryTile (name, entry.get_icon ()+"-symbolic");
                tile.add_css_class ("tile-%s".printf(name.down ()));

                tile.clicked.connect (() => {
                    active_category = entry;
                    var page_name = name.down ();
                    stack.set_visible_child_name (page_name);
                    Application.main_window.show_main_back_button ();
                    
                    // Lazy load the category when it's clicked
                    var row = category_rows[page_name];
                    if (row != null) {
                        row.load_if_needed ();
                    }
                });
                
                featured_flowbox.append (tile);
            }

            Signals.get_default ().window_do_back_button_clicked.connect ((is_album) => {
                // Only respond to main navigation back button (not album back button)
                if (!is_album) {
                    active_category = null;
                    stack.set_transition_type (Gtk.StackTransitionType.SLIDE_RIGHT);
                    stack.set_visible_child_name ("featured");
                    stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT);
                    Application.main_window.hide_main_back_button ();
                }
            });

            // Listen to stack page changes to update back button visibility
            stack.notify["visible-child-name"].connect (() => {
                if (stack.get_visible_child_name () == "featured") {
                    active_category = null;
                    Application.main_window.hide_main_back_button ();
                } else {
                    Application.main_window.show_main_back_button ();
                }
            });

            
            
            //  featured_row_test = new Catalogue.FeaturedRow ("Test Row");
            //  featured_box.append (featured_row_test);

            var client = Core.Client.get_default ();
            
            // Add skeleton tiles to show loading state
            for (var i = 0; i < 8; i++) {
                new_updated.add_widgets_skeleton (new Catalogue.SkeletonTile ());
            }
            
            // Don't load "New & Updated" immediately - wait for realize and use async loading
            var new_updated_loaded = false;
            this.realize.connect (() => {
                if (!new_updated_loaded) {
                    new_updated_loaded = true;
                    ThreadService.run_in_thread.begin<void> (() => {
                        var packages = client.get_new_updated_packages (8);
                        Idle.add (() => {
                            new_updated.reset ();
                            new_updated.add_widgets (packages);
                            return false;
                        });
                    });
                }
            });
            
            client.cache_update_finished.connect (() => {
                if (new_updated_loaded) {
                    ThreadService.run_in_thread.begin<void> (() => {
                        var packages = client.get_new_updated_packages (8);
                        Idle.add (() => {
                            new_updated.reset ();
                            new_updated.add_widgets (packages);
                            return false;
                        });
                    });
                }
            });

            //  GLib.File data = File.new_for_uri (@"$(Config.API_URL)/client/editors_choice");
            //  editors_choice.add_widgets (new CatalogueClient ().get_packages (data));

            accessories_box.append (accessories_row);
            internet_box.append (internet_row);
            develop_box.append (develop_row);
            games_box.append (games_row);
            create_box.append (create_row);
            work_box.append (work_row);
        }
    }
}
