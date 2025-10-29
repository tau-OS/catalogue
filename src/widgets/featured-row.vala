/* widgets/featured-row.vala
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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/featured-row.ui")]
    public class FeaturedRow : He.Bin {
        [GtkChild]
        private unowned He.ContentList row_container;
        [GtkChild]
        private unowned Gtk.FlowBox row_box;

        public string title {
            get {
                return row_container.title;
            }
            set {
                row_container.title = (value);
            }
        }

        public FeaturedRow(string title) {
            this.title = title;
        }

        construct {
            row_box.child_activated.connect ((child) => {
                ((AppTile) child.get_child ()).click ();
            });
        }

        public void reset () {
            var widget_list = new Utils ().get_all_widgets_in_child (row_box);

            foreach (var widget in widget_list) {
                row_box.remove (widget);
            }
        }

        public void add_widgets_skeleton (Gtk.Widget skeleton) {
            row_box.append (skeleton);
        }

        public void add_widgets (Gee.Collection<Catalogue.Core.Package> packages) {
            foreach (var package in packages) {
                var app_tile = new Catalogue.AppTile (package);

                row_box.append (app_tile);
            }
        }
    }
}
