/* dialog/uninstall-warning.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/Dialogs/uninstall-warning.ui")]
    public class UninstallWarningDialog : Gtk.Window {
        [GtkChild]
        private unowned Gtk.Label header;

        public signal void do_uninstall ();

        [GtkCallback]
        public void on_close () {
            this.close ();
        }

        [GtkCallback]
        public void on_uninstall () {
            do_uninstall ();
        }

        public UninstallWarningDialog (Core.Package package) {
            Object ();

            if (package != null) {
                header.set_label ("Uninstall “%s”?".printf (package.get_name ()));
            }
        }
    }
}
