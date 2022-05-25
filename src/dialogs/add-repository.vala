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
    [GtkTemplate (ui = "/co/tauos/Catalogue/Dialogs/add-repository.ui")]
    public class AddRepositoryDialog : Gtk.Window {
        [GtkChild]
        private unowned Gtk.Label title_label;
        [GtkChild]
        private unowned Gtk.Label description_label;

        public Flatpak.Remote global_remote;

        [GtkCallback]
        public void on_close () {
            this.close ();
        }

        [GtkCallback]
        public void on_add () {
            var client = Core.Client.get_default ();
            client.create_remote (global_remote);
            this.close ();
        }

        public AddRepositoryDialog (Flatpak.Remote remote) {
            Object ();

            global_remote = remote;

            title = "%s - %s".printf(remote.get_title (), remote.get_url ());

            title_label.set_label (title);
            description_label.set_label (remote.get_description ());
        }
    }
}
