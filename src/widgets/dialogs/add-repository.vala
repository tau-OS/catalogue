/* dialog/add-repository.vala
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
    public class AddRepositoryDialog : He.Dialog {
        private Flatpak.Remote remote;

        public AddRepositoryDialog (Gtk.Window parent, Flatpak.Remote remote) {
            this.remote = remote;

            var add_button = new He.Button (null, _("Add Repository"));

            base (
                parent,
                "%s - %s".printf(remote.get_title (), remote.get_url ()),
                remote.get_description (),
                "folder-remote-symbolic",
                add_button
            );

            add_button.clicked.connect (() => {
                var client = Core.Client.get_default ();
                client.create_remote (remote);
                hide_dialog ();
            });
        }
    }
}
