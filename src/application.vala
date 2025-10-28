/* application.vala
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
    public class Application : He.Application {
        public static Catalogue.Window main_window { get; set; }

        private Core.Client client;

        private const GLib.OptionEntry[] options = {
            { "details", '\0', 0, OptionArg.STRING, out details_id,
              "Show application details (using application ID)", "ID" },
            { "filename", 'f', 0, OptionArg.FILENAME, out filename,
              "Open a local package file", "FILENAME" },
            { null }
        };

        public static string details_id;
        public static string filename;

        private const GLib.ActionEntry app_entries[] = {
            { "about", on_about_action },
            { "preferences", on_preferences_action },
            { "quit", quit }
        };

        public Application () {
            Object (application_id: Config.APP_ID);
        }

        construct {
            application_id = Config.APP_ID;
            flags = ApplicationFlags.FLAGS_NONE;
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.textdomain (Config.GETTEXT_PACKAGE);
            Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
            Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");

            add_action_entries (app_entries, this);
            add_main_option_entries (options);
            set_accels_for_action ("app.quit", {"<primary>q"});

            typeof (Catalogue.WindowExplore).ensure ();
            typeof (Catalogue.WindowInstalled).ensure ();
            typeof (Catalogue.WindowUpdates).ensure ();
            typeof (Catalogue.Carousel).ensure ();
            typeof (Catalogue.FeaturedRow).ensure ();

            client = Core.Client.get_default ();
            client.cache_update_finished.connect (() => {
                main_window.main_stack.set_visible_child_name ("main_shell");
            });
        }

        public override void open (File[] files, string hint) {
            activate ();

            var file = files[0];
            if (file == null) {
                return;
            }

            if (file.has_uri_scheme ("type")) {
                return;
            }

            if (!file.has_uri_scheme ("appstream") && !file.has_uri_scheme ("catalogue")) {
                return;
            }

            string link = file.get_uri ().replace ("appstream://", "").replace ("catalogue://", "");
            if (link.has_suffix ("/")) {
                link = link.substring (0, link.last_index_of_char ('/'));
            }

            var package = client.get_package_for_component_id (link);
            if (package != null) {
                main_window.view_package_details (package);
            } else {
                info (_("Specified link '%s' could not be found").printf (link));
                return;
            }
        }

        public signal void open_dialog ();

        protected override void startup () {
            Gdk.RGBA accent_color = {};
            accent_color.parse("#8c56bf");
            default_accent_color = He.from_gdk_rgba(accent_color);

            resource_base_path = "/com/fyralabs/Catalogue";

            base.startup ();

            Bis.init ();

            main_window = new Catalogue.Window (this);
        }

        protected override void activate () {
            active_window?.present ();

            client.update_cache.begin ();
            if (details_id != null) {
                var package = client.get_package_for_component_id (details_id);
                if (package == null) {
                    critical ("No package by the ID %s could be found", details_id);
                } else {
                    main_window.view_package_details (package);
                }
            }

            if (filename != null) {
                var flatpak_helper = new FlatpakRefHelper ();
                File file = File.new_for_path (filename);

                // TODO this should support branches
                if (flatpak_helper.get_reference_type (file) == FlatpakRefHelper.REFERENCE_TYPE.FLATPAK_REF) {
                    try {
                        // Verify that remote exists
                        if (
                            client.does_remote_url_exist (flatpak_helper.parse_flatpak_ref (file, "Url")) ||
                            (flatpak_helper.does_key_exist (file, FlatpakRefHelper.REFERENCE_TYPE.FLATPAK_REF, "SuggestRemoteName") && client.does_remote_name_exist (flatpak_helper.parse_flatpak_ref (file, "SuggestRemoteName")))
                        ) {
                            var app = flatpak_helper.parse_flatpak_ref (file, "Name");
                            var package = client.get_package_for_component_id (app);
                            if (package != null) {
                                main_window.view_package_details (package);
                            } else {
                                info ("Package '%s' could not be found".printf (app));
                                return;
                            }
                        } else {
                            ThreadService.run_in_thread.begin<void> (() => {
                                try {
                                    var uri = File.new_for_uri (flatpak_helper.parse_flatpak_ref (file, "RuntimeRepo"));
                                    var bytes = uri.load_bytes (null, null);
                                    var remote = new Flatpak.Remote.from_file (flatpak_helper.parse_flatpak_repo<Bytes> (bytes, "Title", true), bytes);
                                    
                                    Idle.add (() => {
                                        var dialog = new Catalogue.AddRepositoryDialog (main_window, remote);
                                        dialog.present ();
                                        return false;
                                    });
                                } catch (KeyFileError e) {
                                    warning (e.message);
                                } catch (Error e) {
                                    warning (e.message);
                                }
                            });
                        }
                    } catch (KeyFileError e) {
                        warning (e.message);
                    }
                } else if (flatpak_helper.get_reference_type (file) == FlatpakRefHelper.REFERENCE_TYPE.FLATPAK_REPO) {
                    try {

                        // Verify that remote does not exist
                        if (!client.does_remote_url_exist (flatpak_helper.parse_flatpak_repo (file, "Url"))) {
                            var bytes = file.load_bytes (null, null);
                            var remote = new Flatpak.Remote.from_file (flatpak_helper.parse_flatpak_repo<File> (file, "Title"), bytes);
                            var win = this.active_window;
                            if (win == null) {
                                error ("Cannot find main window");
                            }
                            var dialog = new Catalogue.AddRepositoryDialog (win, remote);
                            dialog.present ();
                        } else {
                            warning ("Remote %s already exists".printf (flatpak_helper.parse_flatpak_repo<File> (file, "Title")));
                        }
                    } catch (KeyFileError e) {
                        warning (e.message);
                    } catch (Error e) {
                        warning (e.message);
                    }
                } else {
                    warning ("Unknown file type, cannot process");
                }
            }
        }

        private void on_about_action () {
            var win = this.active_window;
            if (win == null) {
                error ("Cannot find main window");
            }

            var about = new He.AboutWindow (
                win,
                "Catalogue" + Config.NAME_SUFFIX,
                Config.APP_ID,
                Config.VERSION,
                Config.APP_ID,
                "https://github.com/tau-os/catalogue/tree/main/po",
                "https://github.com/tau-os/catalogue/issues/new",
                "https://github.com/tau-os/catalogue",
                // TRANSLATORS: 'Name <email@domain.com>' or 'Name https://website.example'
                {},
                {"Fyra Labs"},
                2023,
                He.AboutWindow.Licenses.GPLV3,
                He.Colors.INDIGO
            );
            about.present ();
        }

        private void on_preferences_action () {
            var win = this.active_window;
            if (win == null) {
                error ("Cannot find main window");
            }

            var preferences = new Catalogue.Preferences ();
            preferences.set_transient_for (win);
            preferences.present ();
        }
    }
}

public static int main (string[] args) {
    var app = new Catalogue.Application ();
    return app.run (args);
}
