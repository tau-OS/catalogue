public class Signals : GLib.Object {
    private static Signals _signals;
    public static unowned Signals get_default () {
        if (_signals == null) {
            _signals = new Signals ();
        }

        return _signals;
    }

    public signal void window_do_back_button_clicked ();
    public signal void window_show_back_button ();
    public signal void window_hide_back_button ();
    public signal void explore_leaflet_open ();
}
