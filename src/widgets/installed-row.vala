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
    public class InstalledRow : He.Bin {
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
        [GtkChild]
        private unowned Gtk.Spinner progress_spinner;

        private Core.Package app;

        //  used to remove elements from rows lol :)
        public signal void action_complete (InstalledRow source, bool was_successful);

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
                Application.main_window.view_package_details (package);
            });

            update_button.clicked.connect (() => {
                update_clicked.begin (package);
            });

            delete_button.clicked.connect (() => {
                var win = ((Window)new Utils ().find_ancestor_of_type<Window>(this));
                var dialog = new Catalogue.UninstallWarningDialog (package);
                dialog.set_transient_for (win);
                dialog.present ();

                dialog.do_uninstall.connect (() => {
                    delete_clicked.begin (package);
                });
            });

            package.change_information.progress_changed.connect (() => {
                Signals.get_default ().updates_progress_bar_change (package, false);
            });

            package.info_changed.connect ((status) => {
                if (status == Core.ChangeInformation.Status.FINISHED) {
                    progress_spinner.set_visible (false);
                    Signals.get_default ().updates_progress_bar_change (package, true);

                    if (package.update_available) {
                        update_button.set_visible (true);
                    } else {
                        delete_button.set_visible (true);
                    }
                }
                if (status == Core.ChangeInformation.Status.RUNNING) {
                    info_button.set_sensitive (false);
                    update_button.set_sensitive (false);
                    delete_button.set_sensitive (false);
                    progress_spinner.set_visible (true);
                }
            });

            this.realize.connect (() => {
                // Set the parent element to be unselectable lol
                ((Gtk.ListBoxRow) this.get_parent ()).selectable = false;
            });
        }

        private async void update_clicked (Core.Package package) {
            info_button.set_sensitive (false);
            update_button.set_sensitive (false);
            // TODO this should still be sensetive but should stop the transaction
            delete_button.set_sensitive (false);
            progress_spinner.set_visible (true);
            try {
                var success = yield package.update ();
                if (success) {
                    action_complete (this, true);
                }
            } catch (Error e) {
                if (!(e is GLib.IOError.CANCELLED)) {
                    critical (e.message);
                }
            }
        }

        private async void delete_clicked (Core.Package package) {
            info_button.set_sensitive (false);
            update_button.set_sensitive (false);
            // TODO this should still be sensetive but should stop the transaction
            delete_button.set_sensitive (false);
            progress_spinner.set_visible (true);

            try {
                var success = yield package.uninstall ();
                if (success) {
                    action_complete (this, true);
                }
            } catch (Error e) {
                if (!(e is GLib.IOError.CANCELLED)) {
                    new FailureDialog (FailureDialog.FailType.UNINSTALL, package).present ();
                    critical (e.message);
                }
            }
        }

        public string get_app_name () {
            return app.get_name ();
        }

        public async void enable_updates (bool is_grouped = true) {
            info_button.set_sensitive (false);
            update_button.set_sensitive (false);
            // TODO this should still be sensetive but should stop the transaction
            delete_button.set_sensitive (false);
            progress_spinner.set_visible (true);
            try {
                var success = yield app.update (is_grouped);
                if (success) {
                    action_complete (this, true);
                }
            } catch (Error e) {
                if (!(e is GLib.IOError.CANCELLED)) {
                    critical (e.message);
                }
            }
        }
    }
}
