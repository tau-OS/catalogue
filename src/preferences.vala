/* preferences.vala
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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/preferences.ui")]
    public class Preferences : He.Window {
        [GtkChild]
        private unowned He.SettingsList repositories_listbox;

        public Preferences () {
            Object ();

            modal = true;
            has_title = true;
                
            var system_repos = Core.Client.get_default ().get_remotes (true);
            var user_repos = Core.Client.get_default ().get_remotes (false);

            foreach (var remote in system_repos) {
                var url = new Utils ().get_uri_hostname (remote.get_url ());

                var row = new He.SettingsRow () {
                    title = remote.get_title (),
                    subtitle = "%s • %s".printf (url, "System Installation")
                };

                var toggle = new Gtk.Switch () {
                    valign = Gtk.Align.CENTER,
                    active = !remote.get_disabled ()
                };

                toggle.state_set.connect (() => {
                    remote.set_disabled (!remote.get_disabled ());
                    Core.Client.get_default ().modify_remote (remote);

                    // Default handler should still be activated
                    return false;
                });

                row.primary_button = (He.Button)(toggle);
                repositories_listbox.add (row);
            }

            foreach (var remote in user_repos) {
                var url = new Utils ().get_uri_hostname (remote.get_url ());

                var row = new He.SettingsRow () {
                    title = remote.get_title (),
                    subtitle = "%s • %s".printf (url, "Per-User Installation")
                };

                var toggle = new Gtk.Switch () {
                    valign = Gtk.Align.CENTER,
                    active = !remote.get_disabled ()
                };

                toggle.state_set.connect (() => {
                    remote.set_disabled (!remote.get_disabled ());
                    Core.Client.get_default ().modify_remote (remote);

                    // Default handler should still be activated
                    return false;
                });

                row.primary_button = (He.Button)(toggle);
                repositories_listbox.add (row);
            }
        }
    }
}
