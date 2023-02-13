/* utils.vala
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
    public class Utils {
        public T find_ancestor_of_type<T> (Gtk.Widget? ancestor) {
            while ((ancestor = ancestor.get_parent ()) != null){
                if (ancestor.get_type ().is_a (typeof (T)))
                    return (T) ancestor;
            }
        
            return null;
        }
        
        public Gtk.Widget[] get_all_widgets_in_child (Gtk.Widget parent) {
            Gtk.Widget[] widgets = {};
            var widget = parent.get_first_child ();
            Gtk.Widget? next = null;
            if (widget != null) {
                widgets += widget;
                while ((next = widget.get_next_sibling ()) != null) {
                    widget = next;
                    widgets += widget;
                }
            }
            return widgets;
        }

        // Adapted from https://gitlab.gnome.org/GNOME/gnome-software/-/blob/main/src/gs-common.c#L853-945
        public string time_to_string (int unix_time_seconds) {
            int minutes_ago;
            int hours_ago;
            int days_ago;
            int weeks_ago;
            int months_ago;
            int years_ago;

            if (unix_time_seconds <= 0) {
                return "";
            }

            var datetime = new DateTime.from_unix_local (unix_time_seconds);
            var now = new DateTime.now_local ();
            var timespan = now.difference (datetime);

            minutes_ago = int.parse ((timespan / TimeSpan.MINUTE).to_string ());
            hours_ago = int.parse ((timespan / TimeSpan.HOUR).to_string ());
            days_ago = int.parse ((timespan / TimeSpan.DAY).to_string ());
            weeks_ago = days_ago / 7;
            months_ago = days_ago / 30;
            years_ago = weeks_ago / 52;

            if (minutes_ago < 5) {
                return "Just now";
            } else if (hours_ago < 1) {
                return ngettext ("%d minute ago", "%d minutes ago", minutes_ago).printf (minutes_ago);
            } else if (days_ago < 1) {
                return ngettext ("%d hour ago", "%d hours ago", hours_ago).printf (hours_ago);
            } else if (days_ago < 15) {
                return ngettext ("%d day ago", "%d days ago", days_ago).printf (days_ago);
            } else if (weeks_ago < 8) {
                return ngettext ("%d week ago", "%d weeks ago", weeks_ago).printf (weeks_ago);
            } else if (years_ago < 1) {
                return ngettext ("%d month ago", "%d months ago", months_ago).printf (months_ago);
            } else {
                return ngettext ("%d year ago", "%d years ago", years_ago).printf (years_ago);
            }
        }

        public string get_uri_hostname (string uri) {
            // SOUP_HTTP_URI_FLAGS
            var url_flags = (UriFlags.ENCODED | UriFlags.ENCODED_FRAGMENT | UriFlags.ENCODED_PATH | UriFlags.ENCODED_QUERY | UriFlags.SCHEME_NORMALIZE);
            string url;

            try {
                url = Uri.parse (uri, url_flags).get_host ();
            } catch (Error e) {
                url = uri;
                warning ("Error parsing URI: %s", e.message);
            }

            return url;
        }

        private static double contrast_ratio (Gdk.RGBA bg_color, Gdk.RGBA fg_color) {
            // From WCAG 2.0 https://www.w3.org/TR/WCAG20/#contrast-ratiodef
            var bg_luminance = get_luminance (bg_color);
            var fg_luminance = get_luminance (fg_color);
        
            if (bg_luminance > fg_luminance) {
                return (bg_luminance + 0.05) / (fg_luminance + 0.05);
            }
        
            return (fg_luminance + 0.05) / (bg_luminance + 0.05);
        }
        
        private static double get_luminance (Gdk.RGBA color) {
            // Values from WCAG 2.0 https://www.w3.org/TR/WCAG20/#relativeluminancedef
            var red = sanitize_color (color.red) * 0.2126;
            var green = sanitize_color (color.green) * 0.7152;
            var blue = sanitize_color (color.blue) * 0.0722;
        
            return red + green + blue;
        }
        
        private static double sanitize_color (double color) {
            // From WCAG 2.0 https://www.w3.org/TR/WCAG20/#relativeluminancedef
            if (color <= 0.03928) {
                return color / 12.92;
            }
        
            return Math.pow ((color + 0.055) / 1.055, 2.4);
        }

        public static Gdk.RGBA contrasting_foreground_color (Gdk.RGBA bg_color) {
            Gdk.RGBA gdk_white = { 1.0f, 1.0f, 1.0f, 1.0f };
            Gdk.RGBA gdk_black = { 0.0f, 0.0f, 0.0f, 1.0f };
        
            var contrast_with_white = contrast_ratio (
                bg_color,
                gdk_white
            );
            var contrast_with_black = contrast_ratio (
                bg_color,
                gdk_black
            );

            var fg_color = gdk_white;

            if ( contrast_with_black > (contrast_with_white + 3.0) ) {
                fg_color = gdk_black;
            }
        
            return fg_color;
        }
        
    }
}
