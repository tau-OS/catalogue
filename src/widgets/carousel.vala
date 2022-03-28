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
    [GtkTemplate (ui = "/co/tauos/Catalogue/carousel.ui")]
    public class Carousel : Gtk.Box {
        [GtkChild]
        private unowned Adw.Carousel carousel;
        [GtkChild]
        private unowned Gtk.Button previous_button;
        [GtkChild]
        private unowned Gtk.Button next_button;

        private void move_relative_page (int page_delta) {
            var animate = true;
            var current_page = carousel.get_position ();
            var pages = carousel.get_n_pages ();
            var new_page = (((int) current_page) + page_delta + pages) % pages;

            var page_widget = carousel.get_nth_page (new_page);

            /* Don’t animate if we’re wrapping from the last page back to the first
             * or from the first page to the last going backwards as it means rapidly
             * spooling through all the pages, which looks confusing. */
            if ((new_page == 0.0 && page_delta > 0) || (new_page == pages - 1 && page_delta < 0)) {
                animate = false;
            }

            carousel.scroll_to (page_widget, animate);
        }

        public Carousel () {
            Object ();
            
            next_button.clicked.connect(() => {
                move_relative_page(1);
            });

            previous_button.clicked.connect(() => {
                move_relative_page(-1);
            });

            carousel.prepend (new Catalogue.CarouselTile ());
        }
    }
}