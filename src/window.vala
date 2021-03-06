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
    [GtkTemplate (ui = "/co/tauos/Catalogue/window.ui")]
    public class Window : He.ApplicationWindow {
        [GtkChild]
        public unowned Gtk.Stack leaflet_stack;
        [GtkChild]
        public unowned Gtk.Stack main_stack;
        [GtkChild]
        private unowned Gtk.Stack header_stack;
        [GtkChild]
        private unowned Gtk.Button back_button;
        [GtkChild]
        private unowned Gtk.Button main_back_button;
        [GtkChild]
        unowned Adw.Leaflet leaflet;
        [GtkChild]
        private unowned Gtk.Box leaflet_contents;
        [GtkChild]
        private unowned Gtk.SearchBar search_bar;
        [GtkChild]
        private unowned Gtk.SearchEntry entry_search;
        [GtkChild]
        private unowned Gtk.ToggleButton search_button;
        [GtkChild]
        private unowned Adw.Bin search_page;

        public void view_package_details (Core.Package package) {
            leaflet_stack.set_visible_child_name ("leaflet_contents");
            leaflet.navigate (Adw.NavigationDirection.BACK);
            back_button.set_visible (true);
            // Add details page to leaflet
            var widget_list = new Utils ().get_all_widgets_in_child (leaflet_contents);

            foreach (var widget in widget_list) {
                leaflet_contents.remove (widget);
            }
            
            leaflet_contents.append (new Catalogue.WindowDetails (package));
        }

        private Catalogue.WindowSearch search_view { get; set; default = new Catalogue.WindowSearch (); }

        private bool should_button_be_shown;

        private const int VALID_QUERY_LENGTH = 3;

        [GtkCallback]
        public void back_clicked_cb () {
            leaflet.set_transition_type (Adw.LeafletTransitionType.OVER);
            leaflet.navigate (Adw.NavigationDirection.FORWARD);
            Signals.get_default ().window_do_back_button_clicked (true);
            leaflet.set_transition_type (Adw.LeafletTransitionType.UNDER);
        }

        [GtkCallback]
        public void main_back_clicked_cb () {
            Signals.get_default ().window_do_back_button_clicked (false);
        }

        [GtkCallback]
        public void search_bar_search_mode_enabled_changed_cb (Object source, GLib.ParamSpec pspec) {
            var child = main_stack.get_visible_child_name ();

            // I want to provide transitions but until I nail the timing, nah
            if (child != "search_shell") {
                search_view.reset ();
                //  main_stack.set_transition_type (Gtk.StackTransitionType.OVER_DOWN);
                main_stack.set_visible_child_name ("search_shell");
            } else {
                //  main_stack.set_transition_type (Gtk.StackTransitionType.UNDER_DOWN);
                main_stack.set_visible_child_name ("main_shell");
            }
        }

        public void leaflet_forward () {
            leaflet.navigate (Adw.NavigationDirection.FORWARD);
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

            search_page.set_child (search_view);

            var go_back = new SimpleAction ("go-back", null);

            go_back.activate.connect (() => {
                if (leaflet.get_visible_child ().get_name () == "leaflet_secondary") {
                    back_clicked_cb ();
                } else {
                    main_back_clicked_cb ();
                }
            });
            this.get_application ().add_action (go_back);

            // i hate accelerators
            var focus_search = new SimpleAction ("focus-search", null);
            focus_search.activate.connect (() => search_button.set_active (!search_button.active));
            this.get_application ().add_action (focus_search);

            app.set_accels_for_action ("win.go-back", {"<Alt>Left", "Back"});
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

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/co/tauos/Catalogue/catalogue.css");
            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
            
            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            default_theme.add_resource_path ("/co/tauos/Catalogue");
            
            should_button_be_shown = false;

            // Handle Rows
            header_stack.notify["visible-child"].connect (() => {
                // Disable search
                search_button.set_active (false);
                if (header_stack.get_visible_child_name () == "explore" && should_button_be_shown == true) {
                    show_back_button ();
                } else {
                    hide_back_button ();
                }
            });

            this.show ();
        }

        public void hide_back_button () {
            main_back_button.set_visible (false);
            if (header_stack.get_visible_child_name () == "explore") {
                should_button_be_shown = false;
            }
        }

        public void show_back_button () {
            main_back_button.set_visible (true);
            should_button_be_shown = true;
        }
    }
}
