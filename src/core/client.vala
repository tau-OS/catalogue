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

namespace Catalogue.Core {
    public class Client : Object {
        public signal void cache_update_finished ();
        
        private GLib.Cancellable cancellable;
        private GLib.DateTime last_cache_update = null;

        private uint update_cache_timeout_id = 0;

        private bool refresh_in_progress = false;

        private const int SECONDS_BETWEEN_REFRESHES = 60 * 60 * 24;

        public static GLib.Settings settings;

        static construct {
            settings = new GLib.Settings (Config.APP_SETTINGS);
        }

        private Client () { }

        construct {
            cancellable = new GLib.Cancellable ();

            last_cache_update = new DateTime.from_unix_utc (settings.get_int64 ("last-refresh-time"));
        }

        // TODO add timer
        public async void update_cache (bool force = false) {
            cancellable.reset ();

            debug ("Updating cache");
            bool success = false;

            // Only update cache one at a time :)
            if (refresh_in_progress) {
                debug ("Update cache already in progress");
                return;
            }

            if (update_cache_timeout_id > 0) {
                if (force) {
                    debug ("Forced update_cache called when there is an on-going timeout - cancelling timeout");
                    Source.remove (update_cache_timeout_id);
                    update_cache_timeout_id = 0;
                } else {
                    debug ("Refresh timeout running and not forced - returning");
                    return;
                }
            }

            var nm = NetworkMonitor.get_default ();

            /* One cache update a day, keeps the doctor away! */
            var seconds_since_last_refresh = new DateTime.now_utc ().difference (last_cache_update) / GLib.TimeSpan.SECOND;
            bool last_cache_update_is_old = seconds_since_last_refresh >= SECONDS_BETWEEN_REFRESHES;

            if (force || last_cache_update_is_old) {
                if (nm.get_network_available ()) {

                    refresh_in_progress = true;
                    try {
                        success = yield FlatpakBackend.get_default ().refresh_cache (cancellable);
                        if (success) {
                            last_cache_update = new DateTime.now_utc ();
                            settings.set_int64 ("last-refresh-time", last_cache_update.to_unix ());
                            print ("Cache updated successfully");
                            cache_update_finished ();
                        }

                        seconds_since_last_refresh = 0;
                    } catch (Error e) {
                        if (!(e is GLib.IOError.CANCELLED)) {
                            critical ("Update_cache: Refesh cache async failed - %s", e.message);
                            cache_update_finished ();
                        }
                    } finally {
                        refresh_in_progress = false;
                    }
                } else {
                    critical ("No Network Available");
                }
            } else {
                debug ("Too soon to refresh and not forced");
                cache_update_finished ();
            }

            var next_refresh = SECONDS_BETWEEN_REFRESHES - (uint)seconds_since_last_refresh;
            debug ("Setting a timeout for a refresh in %f minutes", next_refresh / 60.0f);
            update_cache_timeout_id = GLib.Timeout.add_seconds (next_refresh, () => {
                update_cache_timeout_id = 0;
                update_cache.begin (true);

                return GLib.Source.REMOVE;
            });
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
