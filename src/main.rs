/* main.rs
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

extern crate pretty_env_logger;

mod application;
mod config;
mod macros;
mod window;

use self::application::Application;

use config::{GETTEXT_PACKAGE, LOCALEDIR, RESOURCES_FILE};
use gettextrs::{bindtextdomain, gettext, setlocale, textdomain, LocaleCategory};
use gtk::{gio, glib::set_application_name};

fn main() {
    pretty_env_logger::init();

    // Prepare i18n
    setlocale(LocaleCategory::LcAll, "");
    bindtextdomain(GETTEXT_PACKAGE, LOCALEDIR).expect("Unable to bind the text domain");
    textdomain(GETTEXT_PACKAGE).expect("Unable to switch to the text domain");

    set_application_name(&gettext("Catalogue"));

    let res = gio::Resource::load(RESOURCES_FILE).expect("Could not load resources");
    gio::resources_register(&res);

    let app = Application::new();
    app.run();
}

