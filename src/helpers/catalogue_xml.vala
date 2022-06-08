/* helpers/catalogue_xml.vala
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
    public errordomain XMLError {
        MISSING_TAG,
        FILE_NOT_FOUND
    }

    public class CatalogueRemoteXML {
        public enum TYPE {
            CAROUSEL,
            UNKNOWN // Unknown File
        }

        public TYPE get_xml_type (GLib.File file) throws XMLError {
            Xml.Doc* doc = Xml.Parser.parse_file (file.get_uri ());
            if (doc == null) {
                throw new XMLError.FILE_NOT_FOUND ("File %s not found or permissions missing", file.get_path ());
            }

            Xml.Node* root = doc->get_root_element ();
            if (root == null) {
                throw new XMLError.MISSING_TAG ("Root tag not found");
            }

            for (Xml.Node* iter = root->children; iter != null; iter = iter->next) {
                if (iter->name == "type") {
                    if (iter->get_content() == "carousel") {
                        return TYPE.CAROUSEL;
                    } else {
                        return TYPE.UNKNOWN;
                    }
                }
            }
            
            throw new XMLError.MISSING_TAG ("Missing Type Descriptor");
        }

        public Gee.Collection<Core.Package> get_packages (GLib.File file) throws XMLError {
            Xml.Doc* doc = Xml.Parser.parse_file (file.get_uri ());
            Gee.ArrayList<Core.Package> packages = new Gee.ArrayList<Core.Package> ();
            if (doc == null) {
                throw new XMLError.FILE_NOT_FOUND ("File %s not found or permissions missing", file.get_path ());
            }

            Xml.Node* root = doc->get_root_element ();
            if (root == null) {
                throw new XMLError.MISSING_TAG ("Root tag not found");
            }

            for (Xml.Node* iter = root->children; iter != null; iter = iter->next) {
                if (iter->name == "data") {
                    

                    unowned Core.Client client = Core.Client.get_default ();
                    for (Xml.Node* pkg = iter->children; pkg != null; pkg = pkg->next) {
                        if (pkg->name == "app") {
                            packages.add (client.get_package_for_component_id (pkg->get_content ()));
                        }
                    }
                    return packages;
                }
            }
            
            throw new XMLError.MISSING_TAG ("Missing Type Descriptor");
        }
    }
}
