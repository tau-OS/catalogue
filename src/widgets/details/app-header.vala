/* widgets/details/app-header.vala
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
    [GtkTemplate (ui = "/co/tauos/Catalogue/details/app-header.ui")]
    public class AppHeader : He.Bin {
        [GtkChild]
        private unowned Gtk.Image application_details_icon;
        [GtkChild]
        private unowned Gtk.Label application_details_title;
        [GtkChild]
        private unowned Gtk.Label developer_name_label;
        [GtkChild]
        private unowned Gtk.Button action_button;
        [GtkChild]
        private unowned Gtk.Spinner progress_spinner;

        public ulong handler_id;
            
        public AppHeader (Core.Package app) {
            Object ();

            application_details_title.set_label (app.get_name ());
            if (app.author == null || app.author == "") {
                developer_name_label.set_label (app.author_title);
            } else {
                developer_name_label.set_label (app.author);
            }

            application_details_icon.set_from_gicon (app.get_icon (128, 128));

            app.info_changed.connect ((status) => {
                if (status == Core.ChangeInformation.Status.FINISHED) {
                    progress_spinner.set_visible (false);
                }
            });

            get_state (app);
        }

        private void get_state (Core.Package app) {
            action_button.set_sensitive (true);
            action_button.get_style_context ().remove_class ("suggested-action");
            action_button.get_style_context ().remove_class ("destructive-action");
            if (app.state == Core.Package.State.INSTALLED || app.state == Core.Package.State.UPDATE_AVAILABLE) {
                if (app.state == Core.Package.State.UPDATE_AVAILABLE) {
                    action_button.set_label ("Update");
                    action_button.get_style_context ().add_class ("suggested-action");

                    if (handler_id != 0) {
                        action_button.disconnect (handler_id);
                    }
                    handler_id = action_button.clicked.connect (() => {
                        update_clicked.begin (app);
                    });
                } else {
                    action_button.set_label ("Remove");
                    action_button.get_style_context ().add_class ("destructive-action");

                    if (handler_id != 0) {
                        action_button.disconnect (handler_id);
                    }
                    handler_id = action_button.clicked.connect (() => {
                        var win = ((Window)new Utils ().find_ancestor_of_type<Window>(this));
                        var dialog = new Catalogue.UninstallWarningDialog (app);
                        dialog.set_transient_for (win);
                        dialog.present ();

                        dialog.do_uninstall.connect (() => {
                            remove_clicked.begin (app); 
                        });
                    });
                }
            } else {
                action_button.set_label ("Install");
                action_button.get_style_context ().add_class ("suggested-action");

                if (handler_id != 0) {
                    action_button.disconnect (handler_id);
                }
                handler_id = action_button.clicked.connect (() => {
                    install_clicked.begin (app);
                });
            }
        }

        private async void update_clicked (Core.Package package) {
            // TODO this should still be sensetive but should stop the transaction
            action_button.set_sensitive (false);
            progress_spinner.set_visible (true);
            try {
                yield package.update ();
                get_state (package);
            } catch (Error e) {
                if (!(e is GLib.IOError.CANCELLED)) {
                    critical (e.message);
                }
            }
        }

        private async void install_clicked (Core.Package package) {
            // TODO this should still be sensetive but should stop the transaction
            action_button.set_sensitive (false);
            progress_spinner.set_visible (true);
            try {
                yield package.install ();
                get_state (package);
            } catch (Error e) {
                if (!(e is GLib.IOError.CANCELLED)) {
                    critical (e.message);
                }
            }
        }

        private async void remove_clicked (Core.Package package) {
            // TODO this should still be sensetive but should stop the transaction
            action_button.set_sensitive (false);
            progress_spinner.set_visible (true);
            try {
                yield package.uninstall ();
                get_state (package);
            } catch (Error e) {
                if (!(e is GLib.IOError.CANCELLED)) {
                    critical (e.message);
                }
            }
        }
    }
}
