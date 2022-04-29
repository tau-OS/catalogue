/* widgets/details/app-details.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/details/app-details.ui")]
    public class AppDetails : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Label application_details_summary;
        [GtkChild]
        private unowned Gtk.Label application_details_description;
            
        public AppDetails (Core.Package app) {
            Object ();

            application_details_summary.set_label (app.get_summary ());
            application_details_description.set_label (app.get_description ());
        }
    }
}
 