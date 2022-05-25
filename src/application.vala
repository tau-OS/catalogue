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
    public class Application : Adw.Application {
        public Catalogue.Window main_window { get; set; }

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

            client = Core.Client.get_default ();
            client.cache_update_finished.connect (() => {
                //  if (error) {
                //      print ("TODO add error dialog");
                //  }

                main_window.leaflet_forward ();
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
                Signals.get_default ().explore_leaflet_open (package);
            } else {
                info (_("Specified link '%s' could not be found").printf (link));
                return;
                //  string? search_term = Uri.unescape_string (link);
                //  if (search_term != null) {
                //      main_window.search (search_term);
                //  }
            }
        }

        public signal void open_dialog ();

        protected override void activate () {
            resource_base_path = "/co/tauos/Catalogue";

            base.startup ();

            this.main_window = new Catalogue.Window (this);
            this.main_window.leaflet_stack.set_visible_child_name ("refreshing_cache");
            active_window?.present ();

            client.update_cache.begin ();
            if (details_id != null) {
                var package = client.get_package_for_component_id (details_id);
                if (package == null) {
                    critical ("No package by the ID %s could be found", details_id);
                } else {
                    Signals.get_default ().explore_leaflet_open (package);
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
                                Signals.get_default ().explore_leaflet_open (package);
                            } else {
                                info ("Package '%s' could not be found".printf (app));
                                return;
                            }
                        } else {
                            var dialog = new Catalogue.AddRepositoryDialog ();
                            ThreadService.run_in_thread.begin<void> (() => {
                                try {
                                    var uri = File.new_for_uri (flatpak_helper.parse_flatpak_ref (file, "RuntimeRepo"));
                                    var bytes = uri.load_bytes (null, null);
                                    var remote = new Flatpak.Remote.from_file (flatpak_helper.parse_flatpak_repo<Bytes> (bytes, "Title", true), bytes);
                                    dialog.add_remote (remote);
                                    open_dialog ();
                                } catch (KeyFileError e) {
                                    warning (e.message);
                                } catch (Error e) {
                                    warning (e.message);
                                }
                            });

                            open_dialog.connect (() => {
                                dialog.present ();
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
                            var dialog = new Catalogue.AddRepositoryDialog ();
                            dialog.add_remote (remote);
                            dialog.set_transient_for (win);
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
                    print ("i have no idea wtf this is");
                }
            }
        }

        private void on_about_action () {
            string[] authors = { "Jamie Murphy" };
            string[] artists = { "Jamie Murphy", "Lains https://github.com/lainsce" };
            Gtk.show_about_dialog (this.active_window,
                                   "program-name", "Catalogue" + Config.NAME_SUFFIX,
                                   "authors", authors,
                                   "artists", artists,
                                   "comments", "A nice way to manage the software on your system.",
                                   "copyright", "Made with <3 by Fyra Labs",
                                   "logo-icon-name", Config.APP_ID,
                                   "website", "https://tauos.co",
                                   "website-label", "tauOS Website",
                                   "license-type", Gtk.License.GPL_3_0,
                                   "version", Config.VERSION);
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
