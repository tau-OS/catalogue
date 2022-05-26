/* layout/pages/updates.vala
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

// TODO automatically handle refreshing updates lol
namespace Catalogue {
    [GtkTemplate (ui = "/co/tauos/Catalogue/updates.ui")]
    public class WindowUpdates : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned Adw.StatusPage status_page_up_to_date;
        [GtkChild]
        private unowned Gtk.ListBox listbox;
        [GtkChild]
        private unowned Gtk.ProgressBar progress_bar;

        private Cancellable refresh_cancellable;

        private Gee.List<InstalledRow> rows = new Gee.ArrayList<InstalledRow> ();

        public WindowUpdates () {
            Object ();

            refresh_cancellable = new Cancellable ();

            stack.set_visible_child_name ("refreshing_updates");

            this.realize.connect (() => {
                ThreadService.run_in_thread.begin<void> (() => { get_apps.begin (); });
            });

            Signals.get_default ().updates_progress_bar_change.connect ((package, is_finished) => {
                Idle.add (() => {
                    if (is_finished) {
                        progress_bar.set_visible (false);
                        return GLib.Source.REMOVE;
                    } else {
                        if (progress_bar.get_visible () != true) {
                            progress_bar.set_visible (true);
                        }
                        progress_bar.fraction = package.progress;
                        return GLib.Source.REMOVE;
                    }
                });
            });
            
            var client = Core.Client.get_default ();
            client.installed_apps_changed.connect (() => {
                stack.set_visible_child_name ("refreshing_updates");
                ThreadService.run_in_thread.begin<void> (() => { get_apps.begin (true); });
            });
        }

        public async void get_apps (bool force = false) {
            refresh_cancellable.cancel ();

            refresh_cancellable.reset ();

            reset_apps.begin ();

            unowned Core.Client client = Core.Client.get_default ();

            ThreadService.run_in_thread.begin<void> (() => {
                // TODO figure out why this is lagging everything to hell
                client.refresh_updates.begin (force, (obj, res) => {
                    client.refresh_updates.end (res);
                });
                
                client.get_installed_applications.begin (refresh_cancellable, (obj, packages) => {
                    var installed_apps = client.get_installed_applications.end (packages);

                    if (!refresh_cancellable.is_cancelled ()) {
                        bool does_need_update = false;
                        foreach (var package in installed_apps) {
                            var needs_update = package.state == Core.Package.State.UPDATE_AVAILABLE;
        
                            if (needs_update) {
                                does_need_update = true;
                                var row = new Catalogue.InstalledRow (package);
                                row.action_complete.connect ((source, was_successful) => {
                                    if (was_successful) {
                                        remove_row ((Gtk.ListBoxRow) source.get_parent ());
                                    }
                                });
                                rows.add(row);
                                listbox.append (row);
                            }
                        }
        
                        if (does_need_update) {
                            stack.set_visible_child_name ("updates_available");
                        } else {
                            var time = new DateTime.from_unix_local (client.settings.get_int64 ("last-update-check-time")).format ("%X");
                            if (time != null) {
                                status_page_up_to_date.set_description ("Last checked: %s".printf (time));
                            }
                            stack.set_visible_child_name ("up_to_date");
                        }
                        
                        // Handle runtime updates package
                        var runtime_updates = Core.UpdateManager.get_default ().runtime_updates;
                        if (runtime_updates.state ==Core.Package.State.UPDATE_AVAILABLE) {
                            stack.set_visible_child_name ("updates_available");
                            var row = new Catalogue.InstalledRow (runtime_updates);
                            row.action_complete.connect ((source, was_successful) => {
                                if (was_successful) {
                                    remove_row ((Gtk.ListBoxRow) source.get_parent ());
                                }
                            });
                            rows.add(row);
                            listbox.append (row);
                        }
                    }
                });
            });
        }

        public async void reset_apps () {
            foreach (var widget in new Utils ().get_all_widgets_in_child (listbox)) {
                listbox.remove (widget);
            }
        }

        public void remove_row (Gtk.ListBoxRow row) {
            listbox.remove (row);
            if (listbox.get_first_child ().get_type () != typeof (Gtk.ListBoxRow)) {
                stack.set_visible_child_name ("refreshing_updates");
                ThreadService.run_in_thread.begin<void> (() => { get_apps.begin (true); });
            }
        }

        [GtkCallback]
        public void update_all_packages () {
            foreach (var row in rows) {
                if (row == rows.last ()) {
                    row.enable_updates.begin (false);
                } else {
                    row.enable_updates.begin ();
                }
            }
        }
    }
}
