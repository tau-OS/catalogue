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

            foreach (var entry in categories_list) {
                var name = entry.get_name ();

                // + "-symbolic" needed because the icons shouldn't be full-color here.
                var tile = new Catalogue.CategoryTile (name, entry.get_icon ()+"-symbolic");
                tile.get_style_context ().add_class ("tile-%s".printf(name.down ()));

                tile.clicked.connect (() => {
                    active_category = entry;
                    stack.set_visible_child_name (name.down ());
                    Application.main_window.show_main_back_button ();
                });
                
                featured_flowbox.append (tile);
            }

            Signals.get_default ().window_do_back_button_clicked.connect ((is_album) => {
                if (!is_album) {
                    active_category = null;
                    stack.set_transition_type (Gtk.StackTransitionType.SLIDE_RIGHT);
                    stack.set_visible_child_name ("featured");
                    stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT);
                }

                if (stack.get_visible_child_name () == "featured") {
                    Application.main_window.hide_main_back_button ();
                }
            });

            
            
            //  featured_row_test = new Catalogue.FeaturedRow ("Test Row");
            //  featured_box.append (featured_row_test);

            var client = Core.Client.get_default ();
            new_updated.add_widgets (client.get_new_updated_packages (8));

            //  GLib.File data = File.new_for_uri (@"$(Config.API_URL)/client/editors_choice");
            //  editors_choice.add_widgets (new CatalogueClient ().get_packages (data));

            var accessories_row = new Catalogue.CategoryRow (categories.accessories);
            var internet_row = new Catalogue.CategoryRow (categories.internet);
            var develop_row = new Catalogue.CategoryRow (categories.develop);
            var games_row = new Catalogue.CategoryRow (categories.games);
            var create_row = new Catalogue.CategoryRow (categories.create);
            var work_row = new Catalogue.CategoryRow (categories.work);

            accessories_box.append (accessories_row);
            internet_box.append (internet_row);
            develop_box.append (develop_row);
            games_box.append (games_row);
            create_box.append (create_row);
            work_box.append (work_row);
        }
    }
}
