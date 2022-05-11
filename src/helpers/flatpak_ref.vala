/* helpers/flatpak_ref.vala
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
    public class FlatpakRefHelper {
        public enum REFERENCE_TYPE {
            FLATPAK_REPO, // .flatpakrepo
            FLATPAK_REF, // .flatpakref
            FLATPAK_BUNDLE, // .flatpak
            UNKNOWN // Unknown File
        }

        //  TODO add bundle file support
        public REFERENCE_TYPE get_reference_type (File filename) {
            KeyFile parsed_file = new KeyFile ();

            try {
                parsed_file.load_from_file (filename.get_path (), KeyFileFlags.NONE);
            } catch (KeyFileError e) {
                warning (e.message);
            } catch (FileError e) {
                warning (e.message);
            }

            if (parsed_file.has_group ("Flatpak Repo")) {
                return REFERENCE_TYPE.FLATPAK_REPO;
            } else if (parsed_file.has_group ("Flatpak Ref")) {
                return REFERENCE_TYPE.FLATPAK_REF;
            } else {
                return REFERENCE_TYPE.UNKNOWN;
            }
        }

        public string parse_flatpak_repo (File filename, string key) throws KeyFileError {
            KeyFile parsed_file = new KeyFile ();

            try {
                parsed_file.load_from_file (filename.get_path (), KeyFileFlags.NONE);
            } catch (KeyFileError e) {
                warning (e.message);
            } catch (FileError e) {
                warning (e.message);
            }

            if (parsed_file.has_group ("Flatpak Repo")) {
                string? value = null;
                if (parsed_file.has_key ("Flatpak Repo", key)) {
                    value = parsed_file.get_string ("Flatpak Repo", key);
                } else {
                    throw new KeyFileError.GROUP_NOT_FOUND ("File is missing key %s".printf (key));
                }

                return value;
            } else {
                throw new KeyFileError.GROUP_NOT_FOUND ("File is not Flatpak Repo");
            }
        }

        public string parse_flatpak_ref (File filename, string key) throws KeyFileError {
            KeyFile parsed_file = new KeyFile ();

            try {
                parsed_file.load_from_file (filename.get_path (), KeyFileFlags.NONE);
            } catch (KeyFileError e) {
                warning (e.message);
            } catch (FileError e) {
                warning (e.message);
            }

            if (parsed_file.has_group ("Flatpak Ref")) {
                string? value = null;
                if (parsed_file.has_key ("Flatpak Ref", key)) {
                    value = parsed_file.get_string ("Flatpak Ref", key);
                } else {
                    throw new KeyFileError.GROUP_NOT_FOUND ("File is missing key %s".printf (key));
                }

                return value;
            } else {
                throw new KeyFileError.GROUP_NOT_FOUND ("File is not Flatpak Ref");
            }
        }
    }
}
