/* core/package.vala
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

namespace Catalogue.Core {
    public class PackageDetails : Object {
        public string? name { get; set; }
        public string? description { get; set; }
        public string? summary { get; set; }
        public string? version { get; set; }
    }

    public class Package : Object {
        public enum State {
            NOT_INSTALLED,
            INSTALLED
        }

        public AppStream.Component component { get; protected set; }
        public State state { public get; private set; default = State.NOT_INSTALLED; }

        // Get if package is installed
        private bool _installed = false;
        public bool installed {
            get {
                return _installed;
            }
        }

        public void mark_installed () {
            _installed = true;
            update_state ();
        }

        public void clear_installed () {
            _installed = false;
            update_state ();
        }

        // Get the package author/developer
        private string? _author = null;
        public string author {
            get {
                if (_author != null) {
                    return _author;
                }

                _author = component.developer_name;

                if (_author == null) {
                    var project_group = component.project_group;

                    if (project_group != null) {
                        _author = project_group;
                    }
                }

                return _author;
            }
        }

        public string origin_description {
            owned get {
                var fp_package = this as FlatpakPackage;
                unowned string origin = component.get_origin ();

                // If the package is a system package
                if (fp_package != null && fp_package.installation == FlatpakBackend.system_installation) {
                    return _("%s (system-wide)").printf (origin);
                } else if (origin == "catalogue") {
                    return _("Catalogue");
                } else if (origin == "catalogue-unstable") {
                    return ("Catalogue (Unstable)");
                } else if (origin == "flathub") {
                    return ("Flathub (non-curated)");
                }
    
                return _("Unknown Origin (non-curated)");
            }
        }

        public string? description = null;
        private string? summary = null;
        private string? _latest_version = null;
        public string? latest_version {
            private get { return _latest_version; }
            internal set { _latest_version = convert_version (value); }
        }

        private PackageDetails? backend_details = null;

        public Package (AppStream.Component component) {
            Object (component: component);
        }
    
        public void replace_component (AppStream.Component component) {
            name = null;
            description = null;
            summary = null;
            _author = null;
            _latest_version = null;
            backend_details = null;
    
            this.component = component;
        }

        public void update_state () {
            State new_state;
    
            if (installed) {
                new_state = State.INSTALLED;
            } else {
                new_state = State.NOT_INSTALLED;
            }
    
            // Only trigger a notify if the state has changed, quite a lot of things listen to this
            if (state != new_state) {
                state = new_state;
            }
        }
    
        private string? name = null;
        public string? get_name () {
            if (name != null) {
                return name;
            }
    
            name = component.get_name ();
            if (name == null) {
                if (backend_details == null) {
                    populate_backend_details_sync ();
                }
    
                name = backend_details.name;
            }
    
            name = Core.unescape_markup (name);
    
            return name;
        }
    
        public string? get_description () {
            if (description == null) {
                description = component.get_description ();
    
                if (description == null) {
                    if (backend_details == null) {
                        populate_backend_details_sync ();
                    }
    
                    description = backend_details.description;
                }
    
                if (description == null) {
                    return null;
                }
    
                try {
                    // Condense double spaces
                    var space_regex = new Regex ("\\s+");
                    description = space_regex.replace (description, description.length, 0, " ");
                } catch (Error e) {
                   warning ("Failed to condense spaces: %s", e.message);
                }
    
                try {
                    description = AppStream.markup_convert_simple (description);
                } catch (Error e) {
                    warning ("Failed to convert description to markup: %s", e.message);
                }
            }
    
            return description;
        }
    
        public string? get_summary () {
            if (summary != null) {
                return summary;
            }
    
            summary = component.get_summary ();
            if (summary == null) {
                if (backend_details == null) {
                    populate_backend_details_sync ();
                }
    
                summary = backend_details.summary;
            }
    
            return summary;
        }
    
        public GLib.Icon get_icon (uint size, uint scale_factor) {
            GLib.Icon? icon = null;
            uint current_size = 0;
            uint current_scale = 0;
            uint pixel_size = size * scale_factor;
    
            weak GenericArray<AppStream.Icon> icons = component.get_icons ();
            for (int i = 0; i < icons.length; i++) {
                weak AppStream.Icon _icon = icons[i];
                switch (_icon.get_kind ()) {
                    case AppStream.IconKind.STOCK:
                        unowned string icon_name = _icon.get_name ();
                        if (Gtk.IconTheme.get_for_display (Gdk.Display.get_default ()).has_icon (icon_name)) {
                            return new ThemedIcon (icon_name);
                        }
    
                        break;
                    case AppStream.IconKind.CACHED:
                    case AppStream.IconKind.LOCAL:
                        var icon_scale = _icon.get_scale ();
                        var icon_width = _icon.get_width () * icon_scale;
                        bool is_bigger = (icon_width > current_size && current_size < pixel_size);
                        bool has_better_dpi = (icon_width == current_size && current_scale < icon_scale && scale_factor <= icon_scale);
                        if (is_bigger || has_better_dpi) {
                            var file = File.new_for_path (_icon.get_filename ());
                            icon = new FileIcon (file);
                            current_size = icon_width;
                            current_scale = icon_scale;
                        }
    
                        break;
                    case AppStream.IconKind.REMOTE:
                        var icon_scale = _icon.get_scale ();
                        var icon_width = _icon.get_width () * icon_scale;
                        bool is_bigger = (icon_width > current_size && current_size < pixel_size);
                        bool has_better_dpi = (icon_width == current_size && current_scale < icon_scale && scale_factor <= icon_scale);
                        if (is_bigger || has_better_dpi) {
                            var file = File.new_for_uri (_icon.get_url ());
                            icon = new FileIcon (file);
                            current_size = icon_width;
                            current_scale = icon_scale;
                        }
    
                        break;
                    case AppStream.IconKind.UNKNOWN:
                        icon = new ThemedIcon ("application-default-icon");
                        break;
                }
            }
    
            if (icon == null) {
                icon = new ThemedIcon ("application-default-icon");
            }
    
            return icon;
        }
    
        public string? get_version () {
            if (latest_version != null) {
                return latest_version;
            }
    
            if (backend_details == null) {
                populate_backend_details_sync ();
            }
    
            if (backend_details.version != null) {
                latest_version = backend_details.version;
            }
    
            return latest_version;
        }
    
        private string convert_version (string version) {
            string returned = version;
            returned = returned.split ("+", 2)[0];
            returned = returned.split ("-", 2)[0];
            returned = returned.split ("~", 2)[0];
            if (":" in returned) {
                returned = returned.split (":", 2)[1];
            }
    
            return returned;
        }

        public AppStream.Release? get_newest_release () {
            var releases = component.get_releases ();
            releases.sort_with_data ((a, b) => {
                if (a.get_version () == null || b.get_version () == null) {
                    if (a.get_version () != null) {
                        return -1;
                    } else if (b.get_version () != null) {
                        return 1;
                    } else {
                        return 0;
                    }
                }
    
                return b.vercmp (a);
            });
    
            if (releases.length > 0) {
                return releases[0];
            }
    
            return null;
        }

        private void populate_backend_details_sync () {    
            var loop = new MainLoop ();
            PackageDetails? result = null;
            FlatpakBackend.get_default ().get_package_details.begin (this, (obj, res) => {
                try {
                    result = FlatpakBackend.get_default ().get_package_details.end (res);
                } catch (Error e) {
                    warning (e.message);
                } finally {
                    loop.quit ();
                }
            });
    
            loop.run ();
            backend_details = result;
            if (backend_details == null) {
                backend_details = new PackageDetails ();
            }
        }
    }
}
