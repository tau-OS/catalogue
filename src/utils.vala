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
                //  return "%s".printf (ngettext ("%d month ago", "%d months ago", months_ago), months_ago);
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
    }
}
