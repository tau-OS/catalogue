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

        private Catalogue.Carousel carousel;

        private Catalogue.FeaturedRow featured_row_test;

        public WindowExplore () {
            Object ();

            carousel = new Catalogue.Carousel ();
            // Carousel should always be the top element in the featured page
            featured_box.prepend (carousel);

            // Handle Categories
            var categories = new Gee.HashMap<string, string> ();
            // Key: Category Name
            // Value: Category Icon
            categories.set ("Featured", "starred-symbolic");
            categories.set ("Games", "applications-games-symbolic");
            categories.set ("Develop", "application-x-addon-symbolic");
            categories.set ("Create", "applications-graphics-symbolic");
            categories.set ("Work", "mail-send-symbolic");
            categories.set ("Apps", "view-grid-symbolic");

            foreach (var entry in categories.entries) {
                var tile = new Catalogue.CategoryTile (entry.key, entry.value);

                var name = entry.key;

                tile.clicked.connect (() => {
                    stack.set_visible_child_name (name.down ());
                });
                
                featured_flowbox.append (tile);
            }

            // Handle Rows
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
