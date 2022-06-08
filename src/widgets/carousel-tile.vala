/* widgets/carousel-tile.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/carousel-tile.ui")]
    public class CarouselTile : Gtk.Button {
        [GtkChild]
        private unowned Gtk.Label title;
        [GtkChild]
        private unowned Gtk.Label subtitle;
        [GtkChild]
        private unowned Gtk.Image image;
        
        public CarouselTile (Core.Package package) {
            Object ();

            title.set_label (package.get_name ());
            subtitle.set_label (package.get_summary ());
            image.set_from_gicon (package.get_icon (64, 64));

            this.clicked.connect (() => {
                Application.main_window.view_package_details (package);
            });
        }
    }
}
