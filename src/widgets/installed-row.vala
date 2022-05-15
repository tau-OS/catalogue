/* widgets/installed-row.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/installed-row.ui")]
    public class InstalledRow : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Label app_name;
        [GtkChild]
        private unowned Gtk.Label app_version;
        [GtkChild]
        private unowned Gtk.Image image;
        [GtkChild]
        private unowned Gtk.Button info_button;
        [GtkChild]
        private unowned Gtk.Button delete_button;
        [GtkChild]
        private unowned Gtk.Button update_button;

        private Core.Package app;

        public InstalledRow (Core.Package package) {
            Object ();

            app = package;

            app_name.set_label (app.get_name ());
            app_version.set_label (app.get_version ());

            image.set_from_gicon (app.get_icon (64, 64));

            // TODO show both?
            if (package.update_available) {
                update_button.set_visible (true);
            } else {
                delete_button.set_visible (true);
            }

            info_button.clicked.connect (() => {
                Signals.get_default ().explore_leaflet_open (package);
            });

            update_button.clicked.connect (() => {
                update_clicked.begin (package);
            });

            package.change_information.progress_changed.connect (() => {
                update_progress (package);
            });
        }

        protected void update_progress (Core.Package package) {
            Idle.add (() => {
                print ("%f\n", package.progress);
                return GLib.Source.REMOVE;
            });
        }

        private async void update_clicked (Core.Package package) {
            try {
                yield package.update ();
            } catch (Error e) {
                if (!(e is GLib.IOError.CANCELLED)) {
                    critical (e.message);
                }
            }
        }

        public string get_app_name () {
            return app.get_name ();
        }
    }
}
