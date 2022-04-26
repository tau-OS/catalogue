/* core/client.vala
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

namespace Core {
    public class Client : Object {
        public signal void cache_flush_needed ();

        private GLib.Cancellable cancellable;

        private bool refresh_in_progress = false;

        private Client () { }

        construct {
            cancellable = new GLib.Cancellable ();
        }

        // TODO add timer
        public async void update_cache () {
            cancellable.reset ();

            debug ("Updating cache");
            bool success = false;

            // Only update cache one at a time :)
            if (refresh_in_progress) {
                debug ("Update cache already in progress");
                return;
            }

            var nm = NetworkMonitor.get_default ();
            if (nm.get_network_available ()) {

                refresh_in_progress = true;
                try {
                    success = yield FlatpakBackend.get_default ().refresh_cache (cancellable);
                    if (success) {
                        print ("Cache updated successfully");
                        cache_flush_needed ();
                    }
                } catch (Error e) {
                    if (!(e is GLib.IOError.CANCELLED)) {
                        critical ("Update_cache: Refesh cache async failed - %s", e.message);
                    }
                } finally {
                    refresh_in_progress = false;
                }
            } else {
                critical ("No Network Available");
            }
        }

        public Package? get_package_for_component_id (string id) {
            return FlatpakBackend.get_default ().get_package_for_component_id (id);
        }

        private static GLib.Once<Client> instance;
        public static unowned Client get_default () {
            return instance.once (() => { return new Client (); });
        }
    }
}
