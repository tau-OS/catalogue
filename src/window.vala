/* window.vala
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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/window.ui")]
    public class Window : He.ApplicationWindow {
        [GtkChild]
        public unowned Gtk.Stack main_stack;
        [GtkChild]
        private unowned Gtk.Stack header_stack;
        [GtkChild]
        public unowned He.AppBar header_bar;
        [GtkChild]
        public unowned He.AppBar header_bar3;
        [GtkChild]
        private unowned Gtk.SearchBar search_bar;
        [GtkChild]
        private unowned Gtk.SearchEntry entry_search;
        [GtkChild]
        private unowned Gtk.ToggleButton search_button;
        [GtkChild]
        private unowned Gtk.Box search_page;
        [GtkChild]
        private unowned He.EmptyPage refresh_page;
        [GtkChild]
        private unowned Gtk.Label title_label;
        [GtkChild]
        private unowned Gtk.Box details_container;

        public void view_package_details (Core.Package package) {
            // Clear previous details
            var widget_list = new Utils ().get_all_widgets_in_child (details_container);
            foreach (var widget in widget_list) {
                details_container.remove (widget);
            }

            // Add new details page
            details_container.append (new Catalogue.WindowDetails (package));
            
            // Navigate to details page
            main_stack.set_visible_child_name ("details_page");
            header_bar.show_back = true;
            title_label.label = "";
        }

        private Catalogue.WindowSearch search_view { get; set; default = new Catalogue.WindowSearch (); }

        private const int VALID_QUERY_LENGTH = 3;

        public void back_clicked_cb () {
            // Go back to main shell
            main_stack.set_visible_child_name ("main_shell");
            header_bar.show_back = false;
            
            // Update title based on current page
            if (header_stack.get_visible_child_name () == "explore") {
                title_label.label = _("Explore");
            } else if (header_stack.get_visible_child_name () == "installed") {
                title_label.label = _("Installed");
            } else if (header_stack.get_visible_child_name () == "updates") {
                title_label.label = _("Updates");
            }
            
            Signals.get_default ().window_do_back_button_clicked (true);
        }

        public void main_back_clicked_cb () {
            Signals.get_default ().window_do_back_button_clicked (false);
        }

        [GtkCallback]
        public void search_bar_search_mode_enabled_changed_cb (Object source, GLib.ParamSpec pspec) {
            var child = main_stack.get_visible_child_name ();

            if (child != "search_shell") {
                search_view.reset ();
                main_stack.set_transition_type (Gtk.StackTransitionType.OVER_DOWN);
                main_stack.set_visible_child_name ("search_shell");
            } else {
                main_stack.set_transition_type (Gtk.StackTransitionType.UNDER_DOWN);
                main_stack.set_visible_child_name ("main_shell");
            }
        }

        private void trigger_search () {
            unowned string query = entry_search.text;
            bool query_valid = query.length >= VALID_QUERY_LENGTH;

            if (query_valid) {
                var explore = (Catalogue.WindowExplore) header_stack.get_child_by_name ("explore");
                search_view.search (query, explore.get_active_category ());
            }
        }

        public Window (He.Application app) {
            Object (application: app);

            search_page.append (search_view);
            refresh_page.action_button.visible = false;

            header_bar.back_button.clicked.connect (() => {
                var explore_page = (Catalogue.WindowExplore) header_stack.get_child_by_name ("explore");
                if (explore_page != null && header_stack.get_visible_child_name () == "explore" && main_stack.get_visible_child_name () == "main_shell") {
                    // If we're in explore and showing categories, go back to featured
                    explore_page.reset_to_featured ();
                } else {
                    // Otherwise go back to main view
                    back_clicked_cb ();
                }
            });

            // i hate accelerators
            var focus_search = new SimpleAction ("focus-search", null);
            focus_search.activate.connect (() => search_button.set_active (!search_button.active));
            this.get_application ().add_action (focus_search);

            app.set_accels_for_action ("win.focus-search", {"<Ctrl>f"});

            search_bar.connect_entry ((Gtk.Editable) entry_search);

            var key_press_event = new Gtk.EventControllerKey ();

            key_press_event.key_pressed.connect ((keyval) => {
                if (keyval == Gdk.Key.Escape) {
                    search_button.set_active (!search_button.active);
                    return true;
                }

                return false;
            });

            entry_search.add_controller (key_press_event);

            entry_search.search_changed.connect (() => trigger_search ());

            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            default_theme.add_resource_path ("/com/fyralabs/Catalogue");

            if (header_stack.get_visible_child_name () == "explore") {
                hide_back_button ();
                hide_main_back_button ();
                title_label.label = (_("Explore"));
            } else if (header_stack.get_visible_child_name () == "installed") {
                hide_main_back_button ();
                title_label.label = (_("Installed"));
            } else if (header_stack.get_visible_child_name () == "updates") {
                hide_main_back_button ();
                title_label.label = (_("Updates"));
            } else {
                title_label.label = (_(""));
                show_back_button ();
            }

            header_stack.notify["visible-child"].connect (() => {
                // Disable search
                search_button.set_active (false);
                
                // Get the explore page reference
                var explore_page = (Catalogue.WindowExplore) header_stack.get_child_by_name ("explore");
                
                if (header_stack.get_visible_child_name () == "explore") {
                    hide_back_button ();
                    hide_main_back_button ();
                    title_label.label = (_("Explore"));
                } else {
                    // When navigating away from explore, reset it to featured view
                    if (explore_page != null) {
                        explore_page.reset_to_featured ();
                    }
                    
                    if (header_stack.get_visible_child_name () == "installed") {
                        hide_main_back_button ();
                        title_label.label = (_("Installed"));
                    } else if (header_stack.get_visible_child_name () == "updates") {
                        hide_main_back_button ();
                        title_label.label = (_("Updates"));
                    } else {
                        title_label.label = (_(""));
                        show_back_button ();
                    }
                }
            });

            set_default_size (910, 720);
            this.show ();
        }

        public void hide_main_back_button () {
            header_bar.show_back = (false);
        }

        public void hide_back_button () {
            header_bar.show_back = (false);
        }

        public void show_main_back_button () {
            header_bar.show_back = (true);
        }

        public void show_back_button () {
            header_bar.show_back = (true);
        }
    }
}
