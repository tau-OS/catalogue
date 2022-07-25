/* application.rs
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
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

use gtk::{
    gio::{self, ActionGroup, ActionMap, Settings, ApplicationFlags},
    glib::{self, clone, object_subclass, wrapper, Object},
    subclass::prelude::*,
};
use he::{prelude::*, subclass::prelude::*, AboutWindow, AboutWindowLicenses};

use crate::config::{APP_ID, PKGDATADIR, VERSION};
use crate::window::Window;
use crate::action;
use log::info;

mod imp {
    use super::*;
    use gtk::{
        gio::Settings,
        glib::{self, WeakRef},
    };
    use log::debug;
    use once_cell::sync::OnceCell;

    pub struct Application {
        pub settings: Settings,
        pub window: OnceCell<WeakRef<Window>>,
    }

    impl Default for Application {
        fn default() -> Self {
            Self {
                settings: Settings::new("co.tauos.Catalogue.Settings"),
                window: OnceCell::<WeakRef<Window>>::default(),
            }
        }
    }

    #[object_subclass]
    impl ObjectSubclass for Application {
        const NAME: &'static str = "Application";
        type Type = super::Application;
        type ParentType = he::Application;
    }

    impl ObjectImpl for Application {}
    impl ApplicationImpl for Application {
        fn activate(&self, app: &Self::Type) {
            debug!("HeApplication<Application>::activate");
            self.parent_activate(app);

            if let Some(window) = self.window.get() {
                let window = window.upgrade().unwrap();
                window.present();
                return;
            }

            let window = Window::new(app);
            self.window
                .set(window.downgrade())
                .expect("Window already set.");

            app.main_window().present();
        }

        fn startup(&self, app: &Self::Type) {
            debug!("HeApplication<Application>::startup");
            self.parent_startup(app);

            // Set icons for shell
            gtk::Window::set_default_icon_name(APP_ID);

            app.setup_actions();
            app.setup_accels();
        }
    }

    impl GtkApplicationImpl for Application {}
    impl HeApplicationImpl for Application {}
}

wrapper! {
    pub struct Application(ObjectSubclass<imp::Application>)
        @extends gio::Application, gtk::Application, he::Application,
        @implements ActionGroup, ActionMap;
}

impl Application {
    pub fn new() -> Self {
        Object::new(&[
            ("application-id", &APP_ID),
            ("flags", &ApplicationFlags::default()),
        ])
        .expect("Failed to create Application")
    }

    fn setup_actions(&self) {
        action!(
            self,
            "about",
            clone!(@weak self as app => move |_, _| {
                app.show_about();
            })
        );
        action!(
            self,
            "preferences",
            clone!(@weak self as app => move |_, _| {
                app.show_about();
            })
        );
        action!(
            self,
            "quit",
            clone!(@weak self as app => move |_, _| {
                app.quit()
            })
        );
    }

    fn setup_accels(&self) {
        self.set_accels_for_action("app.quit", &["<Primary>q"]);
    }

    pub fn settings(&self) -> Settings {
        self.imp().settings.clone()
    }

    pub fn main_window(&self) -> Window {
        self.imp().window.get().unwrap().upgrade().unwrap()
    }

    pub fn run(&self) {
        info!("Catalogue ({})", APP_ID);
        info!("Version: {}", VERSION);
        info!("Data: {}", PKGDATADIR);

        ApplicationExtManual::run(self);
    }

    fn show_about(&self) {
        let window = self.active_window().unwrap();
        let uri = "https://github.com/tau-OS/catalogue";
        let developers = vec![
            "Jamie Murphy".into(),
            "Lains".into()
        ];
        AboutWindow::builder()
            .transient_for(&window)
            .modal(true)
            .icon(APP_ID)
            .app_name("Catalogue")
            .version(VERSION)
            .developer_names(developers)
            .copyright_year(2022)
            .license(AboutWindowLicenses::Gplv3)
            .issue_url(uri)
            .more_info_url(uri)
            .build()
            .present();
    }
}

impl Default for Application {
    fn default() -> Self {
        gio::Application::default()
            .unwrap()
            .downcast::<Application>()
            .unwrap()
    }
}

