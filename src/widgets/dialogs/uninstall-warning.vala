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
    public class UninstallWarningDialog : He.Dialog {
        public signal void do_uninstall ();

        public UninstallWarningDialog (Gtk.Window parent, Core.Package package) {
            var uninstall_button = new He.Button (null, _("Uninstall"));
            uninstall_button.add_css_class ("destructive-action");

            base (
                parent,
                _("Uninstall \"%s\"?").printf (package.get_name ()),
                _("Are you sure you want to delete this app?"),
                "emblem-important-symbolic",
                uninstall_button
            );

            uninstall_button.clicked.connect (() => {
                do_uninstall ();
                hide_dialog ();
            });
        }
    }
}
