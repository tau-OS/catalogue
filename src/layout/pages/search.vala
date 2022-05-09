/* layout/pages/search.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/search.ui")]
    public class WindowSearch : Adw.Bin {
        [GtkChild]
        public unowned Gtk.ListBox apps_listbox;

        public string? current_search_term { get; set; default = null; }

        public WindowSearch () {
            Object ();

            apps_listbox.set_sort_func ((row1, row2) => {
                // damn listboxrows
                var p1 = ((SearchRow) row1.get_first_child ());
                var p2 = ((SearchRow) row2.get_first_child ());
                int sp1 = search_priority (p1.get_app_name ());
                int sp2 = search_priority (p2.get_app_name ());
                if (sp1 != sp2) {
                    return sp2 - sp1;
                }

                return p1.get_app_name ().collate (p2.get_app_name ());
            });
        }

        private int search_priority (string name) {
            if (name != null && current_search_term != null) {
                var name_lower = name.down ();
                var query_lower = current_search_term.down ();

                var term_position = name_lower.index_of (query_lower);

                // App name starts with our search term, highest priority
                if (term_position == 0) {
                    return 2;
                // App name contains our search term, high priority
                } else if (term_position != -1) {
                    return 1;
                }
            }

            // Otherwise, normal appstream search ranking order
            return 0;
        }

        public void search (string query, AppStream.Category? category) {
            if (current_search_term != null) {
                current_search_term = null;
            }

            current_search_term = query;
            // why the fuck is this not added into Gtk anymore
            reset ();

            unowned Core.Client client = Core.Client.get_default ();

            Gee.Collection<Core.Package> found_apps;
            found_apps = client.search_applications (query, category);

            foreach (var package in found_apps) {
                apps_listbox.append (new SearchRow (package));
            }
        }

        // Used to reset on listbox open
        public void reset () {
            var widget_list = new Utils ().get_all_widgets_in_child (apps_listbox);

            foreach (var widget in widget_list) {
                apps_listbox.remove (widget);
            }
        }
    }
}
