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
    [GtkTemplate (ui = "/co/tauos/Catalogue/explore.ui")]
    public class WindowExplore : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned Gtk.Box featured_box;
        [GtkChild]
        private unowned Gtk.FlowBox featured_flowbox;
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

        private Catalogue.Carousel carousel;

        private Catalogue.FeaturedRow featured_row_test;

        private void generate_category_row (Catalogue.CategoryRow row, AppStream.Category category) {
            unowned var client = Core.Client.get_default ();

            foreach (var package in client.get_applications_for_category (category)) {
                var package_row = new Catalogue.AppTile (package);

                row.append (package_row);
            }
        }

        public WindowExplore () {
            Object ();

            carousel = new Catalogue.Carousel ();
            // Carousel should always be the top element in the featured page
            featured_box.prepend (carousel);
            
            var categories = new Catalogue.Categories ().get_default ();

            var categories_list = new AppStream.Category[] {};
            categories_list += categories.accessories;
            categories_list += categories.internet; 
            categories_list += categories.develop;
            categories_list += categories.games;
            categories_list += categories.create;
            categories_list += categories.work;

            foreach (var entry in categories_list) {
                var name = entry.get_name ();

                var tile = new Catalogue.CategoryTile (name, entry.get_icon ());

                tile.clicked.connect (() => {
                    stack.set_visible_child_name (name.down ());
                    Signals.get_default ().window_show_back_button ();
                });
                
                featured_flowbox.append (tile);
            }

            Signals.get_default ().window_do_back_button_clicked.connect ((is_leaflet) => {
                if (!is_leaflet) {
                    stack.set_transition_type (Gtk.StackTransitionType.SLIDE_RIGHT);
                    stack.set_visible_child_name ("featured");
                    stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT);
                }

                if (stack.get_visible_child_name () == "featured") {
                    Signals.get_default ().window_hide_back_button ();
                }
            });

            
            
            //  featured_row_test = new Catalogue.FeaturedRow ("Test Row");
            //  featured_box.append (featured_row_test);

            var accessories_row = new Catalogue.CategoryRow ();
            var internet_row = new Catalogue.CategoryRow ();
            var develop_row = new Catalogue.CategoryRow ();
            var games_row = new Catalogue.CategoryRow ();
            var create_row = new Catalogue.CategoryRow ();
            var work_row = new Catalogue.CategoryRow ();

            // shit for other pages
            generate_category_row (accessories_row, categories.accessories);
            generate_category_row (internet_row, categories.internet);
            generate_category_row (develop_row, categories.develop);
            generate_category_row (games_row, categories.games);
            generate_category_row (create_row, categories.create);
            generate_category_row (work_row, categories.work);

            accessories_box.append (accessories_row);
            internet_box.append (internet_row);
            develop_box.append (develop_row);
            games_box.append (games_row);
            create_box.append (create_row);
            work_box.append (work_row);
        }
    }
}
