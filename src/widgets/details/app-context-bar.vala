/* widgets/details/app-context-bar.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/details/app-context-bar.ui")]
    public class AppContextBar : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Label storage_tile_lozenge_content;
        [GtkChild]
        private unowned Gtk.Label storage_tile_description;
            
        public AppContextBar (Core.Package package) {
            Object ();

            get_app_download_size.begin (package);
        }

        private async void get_app_download_size (Core.Package package) {
            if (package.state == Core.Package.State.INSTALLED) {
                return;
            }

            var size = yield package.get_download_size_with_deps ();
            string human_size = GLib.format_size (size);
            storage_tile_lozenge_content.set_label (human_size);
            storage_tile_description.set_label ("Needs up to %s of additional system downloads".printf (human_size));

            tooltip_markup = "<b>%s</b>\n%s".printf (
                _("Actual Download Size Likely to Be Smaller"),
                _("Only the parts of apps and updates that are needed will be downloaded.")
            );
            storage_tile_description.set_tooltip_markup (tooltip_markup);
        }
    }
}
