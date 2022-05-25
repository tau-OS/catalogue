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
        public signal void installed_apps_changed ();

        public ScreenshotCache? screenshot_cache { get; private set; default = new ScreenshotCache (); }
        
        private GLib.Cancellable cancellable;
        private GLib.DateTime last_cache_update = null;
        private GLib.DateTime last_refresh_update = null;

        public uint updates_number { get; private set; default = 0U; }
        
        private uint update_cache_timeout_id = 0;
        private uint refresh_updates_timeout_id = 0;

        private bool refresh_in_progress = false;

        private const int SECONDS_BETWEEN_REFRESHES = 60 * 60 * 24;

        private AsyncMutex update_notification_mutex = new AsyncMutex ();

        public GLib.Settings settings;

        private Client () { }

        construct {
            settings = new GLib.Settings (Config.APP_SETTINGS);

            cancellable = new GLib.Cancellable ();

            last_cache_update = new DateTime.from_unix_utc (settings.get_int64 ("last-refresh-time"));
            last_refresh_update = new DateTime.from_unix_utc (settings.get_int64 ("last-update-check-time"));
        }

        public Package? get_package_for_component_id (string id) {
            return FlatpakBackend.get_default ().get_package_for_component_id (id);
        }

        public async Gee.Collection<Package> get_installed_applications (Cancellable? cancellable = null) {
            var apps = new Gee.TreeSet<Package> ();
            var installed = yield FlatpakBackend.get_default ().get_installed_applications (cancellable);
            if (installed != null) {
                apps.add_all (installed);
            }
            return apps;
        }

        public Gee.Collection<Package> get_applications_for_category (AppStream.Category category) {
            return FlatpakBackend.get_default ().get_applications_for_category (category);
        }

        public Gee.Collection<Package> search_applications (string query, AppStream.Category? category) {
            return FlatpakBackend.get_default ().search_applications (query, category);
        }

        public Gee.ArrayList<Flatpak.Remote> get_remotes (bool use_system) {
            return FlatpakBackend.get_default ().get_remotes (use_system, cancellable);
        }

        public bool modify_remote (Flatpak.Remote remote) {
            return FlatpakBackend.get_default ().modify_remote (remote, cancellable);
        }

        public bool does_remote_url_exist (string url) {
            return FlatpakBackend.get_default ().does_remote_url_exist (url, cancellable);
        }

        public bool does_remote_name_exist (string name) {
            return FlatpakBackend.get_default ().does_remote_name_exist (name, cancellable);
        }

        public bool create_remote (Flatpak.Remote remote) {
            return FlatpakBackend.get_default ().create_remote (remote, true, cancellable);
        }

        //  public async void refresh_updates () {
        //      yield update_notification_mutex.lock ();

        //      bool was_empty = updates_number == 0U;
        //      updates_number = yield UpdateManager.get_default ().get_updates (null);

        //      var application = GLib.Application.get_default ();
        //      if (was_empty && updates_number != 0U) {
        //          string title = ngettext ("Update Available", "Updates Available", updates_number);
        //          string body = ngettext ("%u update is available for your system", "%u updates are available for your system", updates_number).printf (updates_number);
                
        //          var notification = new Notification (title);
        //          notification.set_body (body);
        //          notification.set_icon (new ThemedIcon ("software-update-available"));

        //          application.send_notification ("catalouge.updates", notification);
        //      } else {
        //          application.withdraw_notification ("catalogue.updates");
        //      }

        //      update_notification_mutex.unlock ();
        //      installed_apps_changed ();
        //  }

        public async void refresh_updates (bool force = false) {
            yield update_notification_mutex.lock ();
            cancellable.reset ();

            debug ("Refreshing updates");

            // Only update cache one at a time :)
            if (refresh_in_progress) {
                debug ("A refresh is already in progress");
                return;
            }

            if (refresh_updates_timeout_id > 0) {
                if (force) {
                    debug ("Forced refresh_updates called when there is an on-going timeout - cancelling timeout");
                    Source.remove (refresh_updates_timeout_id);
                    refresh_updates_timeout_id = 0;
                } else {
                    debug ("Refresh timeout running and not forced - returning");
                    return;
                }
            }

            var nm = NetworkMonitor.get_default ();

            /* One cache update a day, keeps the doctor away! */
            var seconds_since_last_refresh = new DateTime.now_utc ().difference (last_refresh_update) / GLib.TimeSpan.SECOND;
            bool last_update_is_old = seconds_since_last_refresh >= SECONDS_BETWEEN_REFRESHES;

            if (force || last_update_is_old) {
                if (nm.get_network_available ()) {

                    refresh_in_progress = true;
                    try {
                        bool was_empty = updates_number == 0U;
                        updates_number = yield UpdateManager.get_default ().get_updates (null);

                        var application = GLib.Application.get_default ();
                        if (was_empty && updates_number != 0U) {
                            string title = ngettext ("Update Available", "Updates Available", updates_number);
                            string body = ngettext ("%u update is available for your system", "%u updates are available for your system", updates_number).printf (updates_number);
                            
                            var notification = new Notification (title);
                            notification.set_body (body);
                            notification.set_icon (new ThemedIcon ("software-update-available"));

                            application.send_notification ("catalouge.updates", notification);

                            installed_apps_changed ();
                        } else {
                            application.withdraw_notification ("catalogue.updates");
                        }

                        seconds_since_last_refresh = 0;
                    } finally {
                        refresh_in_progress = false;
                    }
                } else {
                    critical ("No Network Available");
                }
            } else {
                debug ("Too soon to refresh and not forced");
                installed_apps_changed ();
            }

            var next_refresh = SECONDS_BETWEEN_REFRESHES - (uint)seconds_since_last_refresh;
            debug ("Setting a timeout for a refresh in %f minutes", next_refresh / 60.0f);
            last_refresh_update = new DateTime.now_utc ();
                            settings.set_int64 ("last-update-check-time", last_refresh_update.to_unix ());
            refresh_updates_timeout_id = GLib.Timeout.add_seconds (next_refresh, () => {
                refresh_updates_timeout_id = 0;
                refresh_updates.begin (true);

                return GLib.Source.REMOVE;
            });

            update_notification_mutex.unlock ();
        }

        public async void update_cache (bool force = false) {
            cancellable.reset ();

            debug ("Updating cache");
            bool success = false;

            // Only update cache one at a time :)
            if (refresh_in_progress) {
                debug ("A refresh is already in progress");
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

        private static GLib.Once<Client> instance;
        public static unowned Client get_default () {
            return instance.once (() => { return new Client (); });
        }
    }
}
