
namespace Catalogue {
    [GtkTemplate (ui = "/co/tauos/Catalogue/window.ui")]
    public class Window : Adw.ApplicationWindow {
        //  [GtkChild]
        //  private unowned Gtk.Label label;

        public Window (Adw.Application app) {
            Object (application: app);
        }
    }
}
