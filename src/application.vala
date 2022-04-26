/* application.vala
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
    public class Application : Adw.Application {
        public Catalogue.Window main_window { get; set; }

        private Core.Client client;

        private const GLib.ActionEntry app_entries[] = {
            { "about", on_about_action },
            { "preferences", on_preferences_action },
            { "quit", quit }
        };

        construct {
            application_id = Config.APP_ID;
            flags = ApplicationFlags.FLAGS_NONE;
            add_action_entries (app_entries, this);
            set_accels_for_action ("app.quit", {"<primary>q"});

            client = Core.Client.get_default ();
            client.cache_update_finished.connect (() => {
                //  if (error) {
                //      print ("TODO add error dialog");
                //  }

                main_window.leaflet_forward ();
            });
        }

        protected override void startup () {
            resource_base_path = "/co/tauos/Catalogue";

            base.startup ();

            this.main_window = new Catalogue.Window (this);
        }

        protected override void activate () {
            client.update_cache.begin ();

            active_window?.present ();
        }

        private void on_about_action () {
            string[] authors = { "Jamie Murphy" };
            string[] artists = { "Jamie Murphy", "Lains https://github.com/lainsce" };
            Gtk.show_about_dialog (this.active_window,
                                   "program-name", "Catalogue" + Config.NAME_SUFFIX,
                                   "authors", authors,
                                   "artists", artists,
                                   "comments", "A nice way to manage the software on your system.",
                                   "copyright", "Copyright © 2022 Fyra Labs",
                                   "logo-icon-name", Config.APP_ID,
                                   "website", "https://tauos.co",
                                   "website-label", "tauOS Website",
                                   "license-type", Gtk.License.GPL_3_0,
                                   "version", Config.VERSION);
        }

        private void on_preferences_action () {
            var win = this.active_window;
            if (win == null) {
                error ("Cannot find main window");
            }

            var preferences = new Catalogue.Preferences ();
            preferences.set_transient_for (win);
            preferences.present ();
        }
    }
}

public static int main (string[] args) {
    var app = new Catalogue.Application ();
    return app.run (args);
}
