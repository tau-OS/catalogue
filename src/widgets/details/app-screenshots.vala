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
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned Bis.Carousel carousel;
        [GtkChild]
        private unowned Gtk.Button button_next;
        [GtkChild]
        private unowned Gtk.Button button_previous;
        [GtkChild]
        private unowned Gtk.Revealer button_previous_revealer;
        [GtkChild]
        private unowned Gtk.Revealer button_next_revealer;
            
        public const int MAX_WIDTH = 800;
        GenericArray<AppStream.Screenshot> screenshots;
        public signal void screenshot_downloaded ();

        private void navigate (Bis.NavigationDirection direction) {
            var current_page = carousel.get_position ();
            var pages = carousel.get_n_pages ();
            int page_delta;

            if (direction == Bis.NavigationDirection.BACK) {
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

        public AppScreenshots (Core.Package package) {
            Object ();

            screenshots = package.component.get_screenshots ();

            carousel.page_changed.connect (() => {
                update_buttons ();
            });

            carousel.realize.connect (() => {
                update_buttons ();
            });

            button_previous.clicked.connect (() => {
                navigate (Bis.NavigationDirection.BACK);
            });

            button_next.clicked.connect (() => {
                navigate (Bis.NavigationDirection.FORWARD);
            });

            load_screenshots ();
        }

        private void load_screenshots () {
            var cache = Core.Client.get_default ().screenshot_cache;

            if (screenshots.length == 0) {
                // TODO "no screenshots"
                return;
            }

            List<string> urls = new List<string> ();

            var scale = carousel.get_scale_factor ();
            var min_screenshot_width = MAX_WIDTH * scale;

            screenshots.foreach ((screenshot) => {
                AppStream.Image? best_image = null;
                screenshot.get_images ().foreach ((image) => {
                    // Any image is better then no image
                    if (best_image == null) {
                        best_image = image;
                    }

                    // If our current best is less than the minimum and we have a bigger image, choose that instead
                    if (best_image.get_width () < min_screenshot_width && image.get_width () >= best_image.get_width ()) {
                        best_image = image;
                    }

                    // If our new image is smaller than the current best, but still bigger than the minimum, pick that
                    if (image.get_width () < best_image.get_width () && image.get_width () >= min_screenshot_width) {
                        best_image = image;
                    }
                });

                if (screenshot.get_kind () == AppStream.ScreenshotKind.DEFAULT && best_image != null) {
                    urls.prepend (best_image.get_url ());
                } else if (best_image != null) {
                    urls.append (best_image.get_url ());
                }
            });

            string?[] screenshot_files = new string?[urls.length ()];
            bool[] results = new bool[urls.length ()];
            int completed = 0;

            // Fetch each screenshot in parallel.
            for (int i = 0; i < urls.length (); i++) {
                string url = urls.nth_data (i);
                string? file = null;
                int index = i;

                cache.fetch.begin (url, (obj, res) => {
                    results[index] = cache.fetch.end (res, out file);
                    screenshot_files[index] = file;
                    completed++;
                    screenshot_downloaded ();
                });
            }

            screenshot_downloaded.connect (() => {
                // Load screenshots that were successfully obtained.
                if (urls.length () == completed) {
                    for (int i = 0; i < urls.length (); i++) {
                        if (results[i] == true) {
                            load_screenshot (screenshot_files[i]);
                        }
                    }

                    var number_of_screenshots = carousel.get_n_pages ();

                    if (number_of_screenshots > 0) {
                        stack.set_visible_child_name ("carousel");
                    }
                } else {
                    debug ("Not finished loading all screenshots");
                    return;
                }
            });
        }

        // We need to first download the screenshot locally so that it doesn't freeze the interface.
        private void load_screenshot (string path) {
            var scale_factor = carousel.get_scale_factor ();
            try {
                var pixbuf = new Gdk.Pixbuf.from_file_at_scale (path, MAX_WIDTH * scale_factor, 600 * scale_factor, true);
                var image = new Gtk.Picture.for_pixbuf (pixbuf);
                image.height_request = 423;
                image.halign = Gtk.Align.CENTER;
                image.get_style_context ().add_class ("screenshot-image");
                image.get_style_context ().add_class ("image1");

                image.show ();
                carousel.append (image);
            } catch (Error e) {
                critical (e.message);
            }
        }
    }
}
 
