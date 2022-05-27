/* dialog/failure.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/Dialogs/failure.ui")]
    public class FailureDialog : Gtk.Window {
        [GtkChild]
        private unowned Gtk.Label header;
        [GtkChild]
        private unowned Gtk.Label description;

        [GtkCallback]
        public void on_close () {
            this.close ();
        }

        public enum FailType {
            INSTALL,
            UNINSTALL,
            UPDATE,
            CACHE
        }

        public FailureDialog (FailType type, Core.Package? package) {
            Object ();

            if (type == FailType.UNINSTALL && package != null) {
                header.set_label ("Failed to uninstall %s".printf (package.get_name ()));
                description.set_label ("This may have been caused by external or manually compiled software.");
            } else if (type == FailType.UNINSTALL && package == null) {
                header.set_label ("Failed to uninstall app");
                description.set_label ("This may have been caused by external or manually compiled software.");
            } else if (type == FailType.CACHE) {
                header.set_label ("Failed to fetch cache");
                description.set_label ("This may have been caused by external, manually added software repositories or a corrupted sources file.");
                // TODO add Try Again button
            } else if (type == FailType.UPDATE && package != null) {
                header.set_label ("Failed to update %s".printf (package.get_name ()));
                description.set_label ("This may have been caused by external or manually compiled software.");
            } else if (type == FailType.UPDATE && package == null) {
                header.set_label ("Failed to update app");
                description.set_label ("This may have been caused by external or manually compiled software.");
            } else if (type == FailType.INSTALL && package != null) {
                header.set_label ("Failed to install %s".printf (package.get_name ()));
                description.set_label ("This may be a temporary issue or has been caused by external or manually compiled software.");
            } else if (type == FailType.INSTALL && package == null) {
                header.set_label ("Failed to install app");
                description.set_label ("This may be a temporary issue or has been caused by external or manually compiled software.");
            } else {
                header.set_label ("An unknown error occurred");
                description.set_label ("View the logs for more information");
            }
        }
    }
}
