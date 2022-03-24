
namespace Catalogue {
    [GtkTemplate (ui = "/co/tauos/Catalogue/explore.ui")]
    public class WindowExplore : Adw.Bin {
        [GtkChild]
        private unowned Gtk.ListBox stack_listbox;
        [GtkChild]
        private unowned Gtk.Stack stack;

        private unowned Adw.ActionRow initial_row;

        public WindowExplore () {
            Object ();

            for (var i = 0; i < stack.get_pages ().get_n_items (); i++) {
                var page = ((!) stack.get_pages ().get_object (i)) as Gtk.StackPage;
                
                var row = new Adw.ActionRow () {
                    title = page.get_title (),
                    icon_name = page.get_icon_name (),
                    name = page.get_name ()
                };

                if (i == 0) {
                    initial_row = row;
                }

                stack_listbox.append (row);
            }

            stack_listbox.row_selected.connect ((row) => {
                var page = ((!) row) as Adw.ActionRow;
                stack.set_visible_child_name (page.get_name ());
            });

            stack_listbox.select_row (initial_row);
        }
    }
}
