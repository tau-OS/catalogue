/* window.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned Adw.ViewStack header_stack;

        private Catalogue.WindowExplore explore;
        private Catalogue.WindowInstalled installed;
        private Catalogue.WindowUpdates updates;

        public Window (Adw.Application app) {
            Object (application: app);

            explore = new Catalogue.WindowExplore ();
            installed = new Catalogue.WindowInstalled ();
            updates = new Catalogue.WindowUpdates ();

            header_stack.add_titled (explore, "explore", "Explore");
            var stack_explore = header_stack.get_page (explore);
            ((!) stack_explore).icon_name = "starred-symbolic";

            header_stack.add_titled (installed, "installed", "Installed");
            var stack_installed = header_stack.get_page (installed);
            ((!) stack_installed).icon_name = "folder-download-symbolic";

            header_stack.add_titled (updates, "updates", "Updates");
            var stack_updates = header_stack.get_page (updates);
            ((!) stack_updates).icon_name = "emblem-synchronizing-symbolic";
        }
    }
}
