/* widgets/details/app-versionhistory-row.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/details/app-versionhistory-row.ui")]
    public class AppVersionHistoryRow : Gtk.ListBoxRow {
        [GtkChild]
        private unowned Gtk.Label version_number_label;
        [GtkChild]
        private unowned Gtk.Label version_date_label;
        [GtkChild]
        private unowned Gtk.Label version_description_label;
            
        public AppVersionHistoryRow (AppStream.Release release) {
            Object ();

            string version_number = release.get_version ();
            string version_description = release.get_description ();
            uint64 version_date = release.get_timestamp ();

            string version_date_string = "";
            string version_date_string_tooltip = "";

            if (version_description != null && version_description != "") {
                //  print (version_description);
                version_number_label.set_label (@"New in Version $(version_number)");
                try {
                    version_description_label.set_label (AppStream.markup_convert_simple (version_description));
                } catch (Error e) {
                    version_description_label.set_label ("Error parsing description");
                    warning (e.message);
                }
            } else {
                version_number_label.set_label (@"Version $(version_number)");
                version_description_label.set_label ("No details for this release");
            }

            if (version_date != 0) {
                version_date_string = new Utils ().time_to_string ((int) version_date);

                string format_string = ("%e %B %Y");
                DateTime date_time = new DateTime.from_unix_local ((int) version_date);
                version_date_string_tooltip = date_time.format (format_string);
                version_date_label.set_label (version_date.to_string ());
            }

            if (version_date_string == null) {
                version_date_label.set_visible (false);
            } else {
                version_date_label.set_label (version_date_string);
            }

            if (version_date_string_tooltip != null) {
                version_date_label.set_tooltip_text (version_date_string_tooltip);
            }
        }

    }
}
