/* widgets/app-tile.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/app-tile.ui")]
    public class AppTile : He.MiniContentBlock {
        [GtkChild]
        private unowned He.FillButton price;

        public AppTile (Core.Package package) {
            Object ();

            this.set_title (package.get_name ());
            this.set_subtitle (package.get_summary ());

            price.set_label ("Free");
            this.set_gicon (package.get_icon (64, 64));
            //  image.set_from_gicon (package.get_icon (64, 64));

            price.clicked.connect (() => {
                Signals.get_default ().explore_leaflet_open (package);
            });
        }

        public void click () {
            price.clicked ();
        }
    }
}
