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
    [GtkTemplate (ui = "/co/tauos/Catalogue/details.ui")]
    public class WindowDetails : Adw.Bin {
        [GtkChild]
        private unowned Adw.Bin app_header_container;
        [GtkChild]
        private unowned Adw.Bin app_screenshots_container;
        [GtkChild]
        private unowned Adw.Bin app_details_container;
        [GtkChild]
        private unowned Adw.Bin app_context_container;
        [GtkChild]
        private unowned Adw.Bin app_version_history_container;
        [GtkChild]
        private unowned Adw.Bin app_links_container;
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

            this.realize.connect (() => {
                ThreadService.run_in_thread.begin<void> (() => {
                    app_header_container.set_child (new Catalogue.AppHeader (package));
                    app_screenshots_container.set_child (new Catalogue.AppScreenshots (package));
                    app_details_container.set_child (new Catalogue.AppDetails (package));
                    app_context_container.set_child (new Catalogue.AppContextBar (package));
                    app_version_history_container.set_child (new Catalogue.AppVersionHistory (package));
                    app_links_container.set_child (new Catalogue.AppLinks (package));
                });
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
