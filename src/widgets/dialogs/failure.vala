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
    public class FailureDialog : He.Dialog {
        public enum FailType {
            INSTALL,
            UNINSTALL,
            UPDATE,
            CACHE
        }

        public FailureDialog (Gtk.Window parent, FailType type, Core.Package? package) {
            string title_text;
            string info_text;

            if (type == FailType.UNINSTALL && package != null) {
                title_text = _("Failed to uninstall %s").printf (package.get_name ());
                info_text = _("This may have been caused by external or manually compiled software.");
            } else if (type == FailType.UNINSTALL && package == null) {
                title_text = _("Failed to uninstall app");
                info_text = _("This may have been caused by external or manually compiled software.");
            } else if (type == FailType.CACHE) {
                title_text = _("Failed to fetch cache");
                info_text = _("This may have been caused by external, manually added software repositories or a corrupted sources file.");
            } else if (type == FailType.UPDATE && package != null) {
                title_text = _("Failed to update %s").printf (package.get_name ());
                info_text = _("This may have been caused by external or manually compiled software.");
            } else if (type == FailType.UPDATE && package == null) {
                title_text = _("Failed to update app");
                info_text = _("This may have been caused by external or manually compiled software.");
            } else if (type == FailType.INSTALL && package != null) {
                title_text = _("Failed to install %s").printf (package.get_name ());
                info_text = _("This may be a temporary issue or has been caused by external or manually compiled software.");
            } else if (type == FailType.INSTALL && package == null) {
                title_text = _("Failed to install app");
                info_text = _("This may be a temporary issue or has been caused by external or manually compiled software.");
            } else {
                title_text = _("An unknown error occurred");
                info_text = _("View the logs for more information");
            }

            base (
                parent,
                title_text,
                info_text,
                "dialog-error-symbolic"
            );
        }
    }
}
