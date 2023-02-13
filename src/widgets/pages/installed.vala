/* layout/pages/installed.vala
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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/installed.ui")]
    public class WindowInstalled : Gtk.Box {
        [GtkChild]
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned Gtk.ListBox apps_listbox;
        [GtkChild]
        private unowned Gtk.ProgressBar progress_bar;

        private Cancellable refresh_cancellable;

        private AsyncMutex refresh_mutex = new AsyncMutex ();

        public WindowInstalled () {
            Object ();
        }

        construct {
            refresh_cancellable = new Cancellable ();

            stack.set_visible_child_name ("refreshing_installed");

            this.realize.connect (() => {
                ThreadService.run_in_thread.begin<void> (() => { get_apps.begin (); });
            });

            apps_listbox.set_sort_func ((row1, row2) => {
                return ((Catalogue.InstalledRow) row1.get_first_child ()).get_app_name ().collate (((Catalogue.InstalledRow) row2.get_first_child ()).get_app_name ());
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
                stack.set_visible_child_name ("refreshing_installed");
                ThreadService.run_in_thread.begin<void> (() => { get_apps.begin (); });
            });
        }

        public async void get_apps () {
            refresh_cancellable.cancel ();

            yield refresh_mutex.lock ();

            refresh_cancellable.reset ();

            yield reset_apps ();

            unowned Core.Client client = Core.Client.get_default ();

            ThreadService.run_in_thread.begin<void> (() => {
                client.get_installed_applications.begin (refresh_cancellable, (obj, packages) => {
                    var installed_apps = client.get_installed_applications.end (packages);
                    if (!refresh_cancellable.is_cancelled ()) {
                        foreach (var package in installed_apps) {
                            var row = new Catalogue.InstalledRow (package);
                            row.action_complete.connect ((source, was_successful) => {
                                if (was_successful) {
                                    remove_row ((Gtk.ListBoxRow) source.get_parent ());
                                }
                            });
                            apps_listbox.append (row);
                        }
        
                        if (installed_apps.is_empty) {
                            stack.set_visible_child_name ("no_installed");
                        } else {
                            stack.set_visible_child_name ("installed_packages");
                        }
                    }
                });
            });

            refresh_mutex.unlock ();
        }

        public async void reset_apps () {
            foreach (var widget in new Utils ().get_all_widgets_in_child (apps_listbox)) {
                apps_listbox.remove (widget);
            }
        }

        public void remove_row (Gtk.ListBoxRow row) {
            apps_listbox.remove (row);
            if (apps_listbox.get_first_child ().get_type () != typeof (Gtk.ListBoxRow)) {
                stack.set_visible_child_name ("refreshing_installed");
                ThreadService.run_in_thread.begin<void> (() => { get_apps.begin (); });
            }
        }
    }
}
