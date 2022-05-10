/* daemon.vala
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

namespace Daemon {
    public class Application : GLib.Application {
        private SearchProvider search_provider;
        private uint search_provider_id = 0;

        construct {
            application_id = Config.APP_ID + ".Daemon";
            flags |= ApplicationFlags.FLAGS_NONE;
            search_provider = new SearchProvider ();
        }

        public override void activate () {
            // Keep app running, it's a background process
            new MainLoop ().run ();
        }

        public override bool dbus_register (DBusConnection connection, string object_path) throws Error {
            base.dbus_register (connection, object_path);

            try {
                search_provider_id = connection.register_object ("/co/tauos/Catalogue/SearchProvider", search_provider);
            } catch (Error e) {
                warning (e.message);
            }

            return true;
        }

        public override void dbus_unregister (DBusConnection connection, string object_path) {
            
            if (search_provider_id != 0) {
                connection.unregister_object (search_provider_id);
                search_provider_id = 0;
            }

            base.dbus_unregister (connection, object_path);
        }
    }
}

public static int main (string[] args) {
    var application = new Daemon.Application ();
    return application.run (args);
}
