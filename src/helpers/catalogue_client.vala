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
    public class CatalogueClient {
        public Gee.Collection<Core.Package> get_packages (GLib.File file) {
            Json.Parser parser = new Json.Parser ();
            Gee.ArrayList<Core.Package> packages = new Gee.ArrayList<Core.Package> ();
            try {
                FileInputStream stream = file.read ();
                parser.load_from_stream (stream);
            } catch (Error e) {
                print ("%s\n", e.message);
            }

            Json.Node root = parser.get_root ();

            if (root.get_object ().get_member ("apps").get_node_type () == Json.NodeType.ARRAY) {
                Json.Array apps = root.get_object ().get_member ("apps").get_array ();
                unowned Core.Client client = Core.Client.get_default ();
                apps.get_elements ().foreach ((pkg) => {
                    var package = client.get_package_for_component_id (pkg.get_object ().get_member ("id").get_string ());
                    packages.add (package);
                });
            }

            return packages;
        }
    }
}
