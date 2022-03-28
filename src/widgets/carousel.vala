namespace Catalogue {
    [GtkTemplate (ui = "/co/tauos/Catalogue/carousel.ui")]
    public class Carousel : Gtk.Box {
        [GtkChild]
        private unowned Adw.Carousel carousel;
        [GtkChild]
        private unowned Gtk.Button previous_button;
        [GtkChild]
        private unowned Gtk.Button next_button;

        private void move_relative_page (int page_delta) {
            var animate = true;
            var current_page = carousel.get_position ();
            var pages = carousel.get_n_pages ();
            var new_page = (((int) current_page) + page_delta + pages) % pages;

            var page_widget = carousel.get_nth_page (new_page);

            /* Don’t animate if we’re wrapping from the last page back to the first
             * or from the first page to the last going backwards as it means rapidly
             * spooling through all the pages, which looks confusing. */
            if ((new_page == 0.0 && page_delta > 0) || (new_page == pages - 1 && page_delta < 0)) {
                animate = false;
            }

            // carousel.scroll_to (page_widget, animate);
            // Either Vala or LibAdwaita is being dumb
            carousel.scroll_to (page_widget);
        }

        public Carousel () {
            Object ();
            
            next_button.clicked.connect(() => {
                move_relative_page(1);
            });

            previous_button.clicked.connect(() => {
                move_relative_page(-1);
            });

            carousel.prepend (new Catalogue.CarouselTile ());
        }
    }
}
