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
        public Application () {
            Object (application_id: "co.tauos.Catalogue", flags: ApplicationFlags.FLAGS_NONE);
        }

        construct {
            ActionEntry[] action_entries = {
                { "about", this.on_about_action },
                { "preferences", this.on_preferences_action },
                { "quit", this.quit }
            };
            this.add_action_entries (action_entries, this);
            this.set_accels_for_action ("app.quit", {"<primary>q"});
        }

        public override void activate () {
            base.activate ();
            var win = this.active_window;
            if (win == null) {
                win = new Catalogue.Window (this);
            }

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/co/tauos/Catalogue/catalogue.css");
            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            win.present ();
        }

        private void on_about_action () {
            string[] authors = { "Jamie Murphy" };
            Gtk.show_about_dialog (this.active_window,
                                   "program-name", "Catalogue",
                                   "authors", authors,
                                   "comments", "A nice way to manage the software on your system.",
                                   "copyright", "Copyright © 2022 Innatical, LLC",
                                   "logo-icon-name", "system-software-install",
                                   "website", "https://tauos.co",
                                   "website-label", "tauOS Website",
                                   "license-type", Gtk.License.GPL_3_0,
                                   "version", "1.0.0");
        }

        private void on_preferences_action () {
            message ("app.preferences action activated");
        }
    }
}
