/* widgets/details/app-header.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/details/app-header.ui")]
    public class AppHeader : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Image application_details_icon;
        [GtkChild]
        private unowned Gtk.Label application_details_title;
        [GtkChild]
        private unowned Gtk.Label developer_name_label;
            
        public AppHeader () {
            Object ();

            this.realize.connect (() => {
                var client = Core.Client.get_default ();

                var app = client.get_package_for_component_id ("com.mojang.Minecraft");

                if (app != null) {
                    application_details_title.set_label (app.get_name ());
                    developer_name_label.set_label (app.author);
                    application_details_icon.set_from_gicon (app.get_icon (128, 128));
                } else {
                    print ("null app :/");
                }
            });
        }
    }
}
