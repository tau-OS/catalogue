/* widgets/details/app-screenshots.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/details/app-screenshots.ui")]
    public class AppScreenshots : Gtk.Box {
        [GtkChild]
        private unowned Adw.Carousel carousel;
        [GtkChild]
        private unowned Gtk.Button button_next;
        [GtkChild]
        private unowned Gtk.Button button_previous;
        [GtkChild]
        private unowned Gtk.Revealer button_previous_revealer;
        [GtkChild]
        private unowned Gtk.Revealer button_next_revealer;
            

        private void navigate (Adw.NavigationDirection direction) {
            var current_page = carousel.get_position ();
            var pages = carousel.get_n_pages ();
            int page_delta;

            if (direction == Adw.NavigationDirection.BACK) {
                page_delta = -1;
            } else {
                page_delta = 1;
            }

            var new_page = (((int) current_page) + page_delta + pages) % pages;

            var page_widget = carousel.get_nth_page (new_page);

            carousel.scroll_to (page_widget, true);
        }

        private void update_buttons () {
            var position = carousel.get_position ();
            var n_pages = carousel.get_n_pages ();

            if (n_pages == 1) {
                button_previous_revealer.set_reveal_child (false);
                button_next_revealer.set_reveal_child (false);
            } else if (position == 0) {
                button_previous_revealer.set_reveal_child (false);
                button_next_revealer.set_reveal_child (true);
            } else if (position == (n_pages - 1)) {
                button_next_revealer.set_reveal_child (false);
                button_previous_revealer.set_reveal_child (true);
            } else {
                button_next_revealer.set_reveal_child (true);
                button_previous_revealer.set_reveal_child (true);
            }
        }

        public AppScreenshots () {
            Object ();

            carousel.page_changed.connect (() => {
                update_buttons ();
            });

            carousel.realize.connect (() => {
                update_buttons ();
            });

            button_previous.clicked.connect (() => {
                navigate (Adw.NavigationDirection.BACK);
            });

            button_next.clicked.connect (() => {
                navigate (Adw.NavigationDirection.FORWARD);
            });
        }
    }
}
 