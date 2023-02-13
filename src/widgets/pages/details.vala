/* layout/pages/details.vala
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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/details.ui")]
    public class WindowDetails : He.Bin {
        [GtkChild]
        private unowned He.Bin app_header_container;
        [GtkChild]
        private unowned He.Bin app_screenshots_container;
        [GtkChild]
        private unowned He.Bin app_details_container;
        [GtkChild]
        private unowned He.Bin app_context_container;
        [GtkChild]
        private unowned He.Bin app_version_history_container;
        [GtkChild]
        private unowned He.Bin app_links_container;
        [GtkChild]
        private unowned Gtk.ProgressBar progress_bar;

        public WindowDetails (Core.Package package) {
            Object ();

            package.change_information.progress_changed.connect (() => {
                progress_bar_change (package, false);
            });

            package.info_changed.connect ((status) => {
                if (status == Core.ChangeInformation.Status.FINISHED) {
                    progress_bar_change (package, true);
                }
            });

            Application.main_window.show_back_button ();

            ThreadService.run_in_thread.begin<void> (() => {
                new Catalogue.AppHeader (package).set_parent(app_header_container);
                new Catalogue.AppScreenshots (package).set_parent(app_screenshots_container);
                new Catalogue.AppDetails (package).set_parent(app_details_container);
                new Catalogue.AppContextBar (package).set_parent(app_context_container);
                new Catalogue.AppVersionHistory (package).set_parent(app_version_history_container);
                new Catalogue.AppLinks (package).set_parent(app_links_container);
            });
        }

        private void progress_bar_change (Core.Package package, bool is_finished) {
            Idle.add (() => {
                if (is_finished) {
                    progress_bar.set_visible (false);
                    return GLib.Source.REMOVE;
                } else {
                    if (progress_bar.get_visible () != true) {
                        progress_bar.set_visible (true);
                    }
                    progress_bar.fraction = package.progress;
                    return GLib.Source.REMOVE;
                }
            });
        }
    }
}
