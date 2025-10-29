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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/details/app-screenshots.ui")]
    public class AppScreenshots : Gtk.Box {
        [GtkChild]
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned Gtk.Box carousel_box;

        private He.SnapScrollBox carousel;
            
        public const int MAX_WIDTH = 300;
        GenericArray<AppStream.Screenshot> screenshots;
        public signal void screenshot_downloaded ();

        public AppScreenshots (Core.Package package) {
            Object ();

            screenshots = package.component.get_screenshots_all ();

            carousel = new He.SnapScrollBox ();
            carousel.height_request = 300;
            carousel.vexpand = true;

            carousel_box.append (carousel);

            load_screenshots ();
        }

        private void load_screenshots () {
            var cache = Core.Client.get_default ().screenshot_cache;

            if (screenshots.length == 0) {
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
                    bool has_screenshots = false;
                    for (int i = 0; i < urls.length (); i++) {
                        if (results[i] == true) {
                            load_screenshot (screenshot_files[i]);
                            has_screenshots = true;
                        }
                    }

                    if (has_screenshots) {
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
            try {
                var image = new Gtk.Picture.for_filename (path);
                image.height_request = 300;
                image.halign = Gtk.Align.CENTER;
                image.content_fit = Gtk.ContentFit.CONTAIN;
                image.can_shrink = true;
                image.add_css_class ("screenshot-image");
                image.add_css_class ("image1");

                image.show ();
                carousel.add_item (image);
            } catch (Error e) {
                critical (e.message);
            }
        }
    }
}
