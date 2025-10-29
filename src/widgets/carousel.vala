/* widgets/carousel.vala
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
    public class Carousel : He.SnapScrollBox {
        private void fill_carousel () {
            GLib.File data = File.new_for_uri (@"$(Config.API_URL)/client/carousel");
            foreach (var package in new CatalogueClient ().get_packages (data)) {
                var tile = new Catalogue.CarouselTile (package);
                add_item (tile);
            }
        }

        public Carousel () {
            Object ();
        }

        construct {
            show_button = false;

            ThreadService.run_in_thread.begin<void> (() => {
               fill_carousel ();
            });
        }
    }
}
