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
            string[] authors = { "Jamie Lee" };
            Gtk.show_about_dialog (this.active_window,
                                   "program-name", "Catalogue",
                                   "authors", authors,
                                   "comments", "A nice way to manage the software on your system.",
                                   "copyright", "Copyright © 2022 Innatical, LLC",
                                   "logo-icon-name", "system-software-install",
                                   "website", "https://tauos.co",
                                   "website-label", "tauOS Website",
                                   "version", "1.0.0");
        }

        private void on_preferences_action () {
            message ("app.preferences action activated");
        }
    }
}
