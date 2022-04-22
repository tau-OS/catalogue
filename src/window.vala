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
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned Adw.ViewStack header_stack;
        [GtkChild]
        private unowned Gtk.Button back_button;

        private Catalogue.WindowExplore explore;
        private Catalogue.WindowInstalled installed;
        private Catalogue.WindowUpdates updates;

        private bool should_button_be_shown;

        [GtkCallback]
        public void back_clicked_cb (Gtk.Button source) {
            Signals.get_default ().window_do_back_button_clicked ();
        }

        public Window (Adw.Application app) {
            Object (application: app);

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/co/tauos/Catalogue/catalogue.css");
            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            explore = new Catalogue.WindowExplore ();
            installed = new Catalogue.WindowInstalled ();
            updates = new Catalogue.WindowUpdates ();
            
            should_button_be_shown = false;

            Signals.get_default ().window_show_back_button.connect (() => {
                back_button.set_visible (true);
                should_button_be_shown = true;
            });
            Signals.get_default ().window_hide_back_button.connect (() => {
                back_button.set_visible (false);
                if (header_stack.get_visible_child_name () == "explore") {
                    should_button_be_shown = false;
                }
            });

            header_stack.add_titled (explore, "explore", "Explore");
            var stack_explore = header_stack.get_page (explore);
            ((!) stack_explore).icon_name = "starred-symbolic";

            header_stack.add_titled (installed, "installed", "Installed");
            var stack_installed = header_stack.get_page (installed);
            ((!) stack_installed).icon_name = "folder-download-symbolic";

            header_stack.add_titled (updates, "updates", "Updates");
            var stack_updates = header_stack.get_page (updates);
            ((!) stack_updates).icon_name = "emblem-synchronizing-symbolic";

            header_stack.notify["visible-child"].connect (() => {
                if (header_stack.get_visible_child_name () == "explore" && should_button_be_shown == true) {
                    Signals.get_default ().window_show_back_button ();
                } else {
                    Signals.get_default ().window_hide_back_button ();
                }
            });

            this.show ();
        }
    }
}
