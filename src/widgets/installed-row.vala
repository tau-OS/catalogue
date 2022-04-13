/* widgets/installed-row.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/installed-row.ui")]
    public class InstalledRow : Adw.ActionRow {
        [GtkChild]
        private unowned Gtk.Image image;
        [GtkChild]
        private unowned Gtk.Button suffix_button;

        // TODO pass an application for details
        public InstalledRow (string title, string button_label) {
            Object ();

            this.set_title (title);

            image.set_from_resource ("/co/tauos/Catalogue/test-icon.png");
            suffix_button.set_label (button_label);
            
        }
    }
}
