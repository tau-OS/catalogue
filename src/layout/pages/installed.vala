/* layout/pages/installed.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/installed.ui")]
    public class WindowInstalled : Adw.Bin {
        [GtkChild]
        private unowned Adw.PreferencesGroup in_progress;
        [GtkChild]
        private unowned Adw.PreferencesGroup apps;

        public WindowInstalled () {
            Object ();

            in_progress.add (new Catalogue.InstalledRow ("UwU App", "Stop"));
            apps.add (new Catalogue.InstalledRow ("Second UwU App", "Uninstall"));
            apps.add (new Catalogue.InstalledRow ("Second UwU App", "Uninstall"));
            apps.add (new Catalogue.InstalledRow ("Second UwU App", "Uninstall"));
            apps.add (new Catalogue.InstalledRow ("Second UwU App", "Uninstall"));
            apps.add (new Catalogue.InstalledRow ("Second UwU App", "Uninstall"));
            apps.add (new Catalogue.InstalledRow ("Second UwU App", "Uninstall"));
            apps.add (new Catalogue.InstalledRow ("Second UwU App", "Uninstall"));
        }
    }
}
