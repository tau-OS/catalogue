use crate::application::Application;
use gtk::{
    gio::{ActionGroup, ActionMap},
    glib::{self, Object, wrapper},
    ApplicationWindow, Root, Widget,
};
use he::prelude::*;

mod imp {
    use gtk::{
        glib::{self, subclass::InitializingObject, object_subclass},
        subclass::prelude::*,
        CompositeTemplate,
        Inhibit
    };
    use he::{prelude::*, subclass::prelude::*, ApplicationWindow};
    use log::debug;

    use crate::{
        config::APP_ID,
    };

    #[derive(Default, CompositeTemplate)]
    #[template(resource = "/co/tauos/Catalogue/window.ui")]
    pub struct Window {}

    #[object_subclass]
    impl ObjectSubclass for Window {
        const NAME: &'static str = "CatalogueWindow";
        type Type = super::Window;
        type ParentType = ApplicationWindow;

        fn class_init(klass: &mut Self::Class) {
            klass.bind_template();
        }

        fn instance_init(obj: &InitializingObject<Self>) {
            obj.init_template();
        }
    }

    impl HeApplicationWindowImpl for Window {}
    impl ApplicationWindowImpl for Window {}
    impl WindowImpl for Window {
        fn close_request(&self, window: &Self::Type) -> Inhibit {
            if let Err(err) = window.save_window_size() {
                log::warn!("Failed to save window state, {}", &err);
            }

            // Pass close request on to the parent
            self.parent_close_request(window)
        }
    }
    impl ObjectImpl for Window {
        fn constructed(&self, obj: &Self::Type) {
            self.parent_constructed(obj);

            obj.connect_realize(move |_| {
                debug!("HeWindow<Window>::realize");
            });

            if APP_ID.ends_with("Devel") {
                obj.add_css_class("devel");
            }

            obj.load_window_size();
        }
    }
    impl WidgetImpl for Window {}
}

wrapper! {
    pub struct Window(ObjectSubclass<imp::Window>)
        @extends Widget, gtk::Window, ApplicationWindow, he::ApplicationWindow, ActionMap, ActionGroup,
        @implements Root;

}

impl Window {
    pub fn new(app: &Application) -> Self {
        Object::new(&[("application", app)]).expect("Failed to create Window")
    }

    fn save_window_size(&self) -> Result<(), glib::BoolError> {
        let settings = Application::settings(&Application::default());

        let (width, height) = self.default_size();

        settings.set_int("window-width", width)?;
        settings.set_int("window-height", height)?;

        settings.set_boolean("is-maximized", self.is_maximized())?;

        Ok(())
    }

    fn load_window_size(&self) {
        let settings = Application::settings(&Application::default());

        let width = settings.int("window-width");
        let height = settings.int("window-height");
        let is_maximized = settings.boolean("is-maximized");

        self.set_default_size(width, height);

        if is_maximized {
            self.maximize();
        }
    }
}
