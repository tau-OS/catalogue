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
        private unowned Adw.Leaflet leaflet;
        [GtkChild]
        private unowned Gtk.ListBox stack_listbox;
        [GtkChild]
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned Gtk.Box featured_box;
        [GtkChild]
        private unowned Gtk.FlowBox featured_flowbox;
        [GtkChild]
        private unowned Gtk.Box games_box;
        [GtkChild]
        private unowned Gtk.Box develop_box;
        [GtkChild]
        private unowned Gtk.Box create_box;
        [GtkChild]
        private unowned Gtk.Box work_box;
        [GtkChild]
        private unowned Gtk.Box apps_box;

        private unowned Adw.ActionRow initial_row;
        private Catalogue.Carousel carousel;

        private Catalogue.FeaturedRow featured_row_test;

        public WindowExplore () {
            Object ();

            for (var i = 0; i < stack.get_pages ().get_n_items (); i++) {
                var page = ((!) stack.get_pages ().get_object (i)) as Gtk.StackPage;
                
                var row = new Adw.ActionRow () {
                    title = page.get_title (),
                    icon_name = page.get_icon_name (),
                    name = page.get_name ()
                };

                if (i == 0) {
                    initial_row = row;
                }

                stack_listbox.append (row);
            }

            stack_listbox.row_selected.connect ((row) => {
                var page = ((!) row) as Adw.ActionRow;
                stack.set_visible_child_name (page.get_name ());
            });

            stack_listbox.select_row (initial_row);

            carousel = new Catalogue.Carousel ();
            // Carousel should always be the top element in the featured page
            featured_box.prepend (carousel);

            featured_flowbox.append (new Catalogue.CategoryTile ("Featured", "starred-symbolic"));
            featured_flowbox.append (new Catalogue.CategoryTile ("Games", "applications-games-symbolic"));
            featured_flowbox.append (new Catalogue.CategoryTile ("Develop", "application-x-addon-symbolic"));
            featured_flowbox.append (new Catalogue.CategoryTile ("Create", "applications-graphics-symbolic"));
            featured_flowbox.append (new Catalogue.CategoryTile ("Work", "mail-send-symbolic"));
            featured_flowbox.append (new Catalogue.CategoryTile ("Apps", "view-grid-symbolic"));


            featured_row_test = new Catalogue.FeaturedRow ("Test Row");
            featured_row_test.explore_leaflet_open.connect (() => {
                leaflet.navigate (Adw.NavigationDirection.FORWARD);
            });
            featured_box.append (featured_row_test);

            var games_row = new Catalogue.CategoryRow ();
            games_row.explore_leaflet_open.connect (() => {
                leaflet.navigate (Adw.NavigationDirection.FORWARD);
            });
            var develop_row = new Catalogue.CategoryRow ();
            develop_row.explore_leaflet_open.connect (() => {
                leaflet.navigate (Adw.NavigationDirection.FORWARD);
            });
            var create_row = new Catalogue.CategoryRow ();
            create_row.explore_leaflet_open.connect (() => {
                leaflet.navigate (Adw.NavigationDirection.FORWARD);
            });
            var work_row = new Catalogue.CategoryRow ();
            work_row.explore_leaflet_open.connect (() => {
                leaflet.navigate (Adw.NavigationDirection.FORWARD);
            });
            var apps_row = new Catalogue.CategoryRow ();
            apps_row.explore_leaflet_open.connect (() => {
                leaflet.navigate (Adw.NavigationDirection.FORWARD);
            });

            // shit for other pages
            games_box.append (games_row);
            develop_box.append (develop_row);
            create_box.append (create_row);
            work_box.append (work_row);
            apps_box.append (apps_row);
        }
    }
}
