/* core/utils.vala
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
    public static uint get_file_age (GLib.File file) {
        FileInfo info;
        try {
            info = file.query_info (FileAttribute.TIME_MODIFIED, FileQueryInfoFlags.NONE);
        } catch (Error e) {
            warning ("Error while getting file age: %s", e.message);
            return uint.MAX;
        }

        if (info == null) {
            return uint.MAX;
        }

        uint64 mtime = info.get_attribute_uint64 (FileAttribute.TIME_MODIFIED);
        uint64 now = (uint64) time_t ();

        if (mtime > now) {
            return uint.MAX;
        }

        if (now - mtime > uint.MAX) {
            return uint.MAX;
        }

        return (uint) (now - mtime);
    }

    public static string unescape_markup (string escaped_text) {
        return escaped_text.replace ("&amp;", "&")
                           .replace ("&lt;", "<")
                           .replace ("&gt;", ">")
                           .replace ("&#39;", "'");
    }

    public void delete_folder_contents (File folder, Cancellable? cancellable = null) {
        FileEnumerator enumerator;
        try {
            enumerator = folder.enumerate_children (
                GLib.FileAttribute.STANDARD_NAME + "," + GLib.FileAttribute.STANDARD_TYPE,
                FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
                cancellable
            );
        } catch (Error e) {
            warning ("Unable to create enumerator to cleanup flatpak metadata: %s", e.message);
            return;
        }

        FileInfo? info = null;
        try {
            while (!cancellable.is_cancelled () && (info = enumerator.next_file (cancellable)) != null) {
                if (info.get_file_type () != FileType.DIRECTORY) {
                    var child = folder.resolve_relative_path (info.get_name ());
                    debug ("Deleting %s", child.get_path ());
                    child.delete ();
                } else {
                    var child = folder.resolve_relative_path (info.get_name ());
                    delete_folder_contents (child, cancellable);
                    child.delete ();
                }
            }
        } catch (Error e) {
            warning ("Error while cleaning up flatpak metadat directory: %s", e.message);
        }
    }

    public static void perform_xml_fixups (string origin_name, File src_file, File dest_file) {
        var path = src_file.get_path ();
        
        // Handle gzipped files
        Xml.Doc* doc = null;
        if (path.has_suffix (".gz")) {
            try {
                var converter = new ZlibDecompressor (ZlibCompressorFormat.GZIP);
                var input_stream = src_file.read ();
                var decompressed_stream = new ConverterInputStream (input_stream, converter);
                
                var data_stream = new DataInputStream (decompressed_stream);
                var builder = new StringBuilder ();
                string line = null;
                
                while ((line = data_stream.read_line ()) != null) {
                    builder.append (line);
                    builder.append_c ('\n');
                }
                
                doc = Xml.Parser.parse_doc (builder.str);
            } catch (Error e) {
                warning ("Error decompressing gzipped AppStream file %s: %s", path, e.message);
                return;
            }
        } else {
            doc = Xml.Parser.parse_file (path);
        }
        
        if (doc == null) {
            warning ("Appstream XML file %s not found or permissions missing", path);
            return;
        }

        Xml.Node* root = doc->get_root_element ();
        if (root == null) {
            delete doc;
            warning ("The xml file '%s' is empty", path);
            return;
        }

        if (root->name != "components") {
            delete doc;
            warning ("The root node of %s isn't 'components', valid appstream file?", path);
            return;
        }

        Xml.Attr* origin_attr = root->has_prop ("origin");
        if (origin_attr == null) {
            delete doc;
            warning ("The root node of %s doesn't have an origin attribute, valid appstream file?", path);
            return;
        }

        root->set_prop ("origin", origin_name);

        // FIXME: This is a workaround for https://github.com/ximion/appstream/issues/339
        // Remap the <metadata> tag that contains the custom x-appcenter-xxx values to
        // <custom> as expected by the AppStream parser
        Xml.XPath.Context cntx = new Xml.XPath.Context (doc);
        Xml.XPath.Object* res = cntx.eval_expression ("/components/component/metadata");

        if (res != null && res->type == Xml.XPath.ObjectType.NODESET && res->nodesetval != null) {
            for (int i = 0; i < res->nodesetval->length (); i++) {
                Xml.Node* node = res->nodesetval->item (i);
                node->set_name ("custom");
            }
        }

        /* The below sorting is a workaround for the fact that libappstream uses app ID + remote as a unique
         * key for an app, and any subsequent duplicates found in the XML are discarded. So if there's a "stable"
         * branch and a "daily" branch for an application from the same remote, and the daily branch happens to come
         * first in the file, libappstream throws away the AppData for the stable version.
         *
         * See https://github.com/elementary/appcenter/issues/1612 for details
         */
        var sorted_components = new Gee.ArrayList<Xml.Node*> ();
        // Iterate through all components in the appstream XML
        for (Xml.Node* component = root->children; component != null; component = component->next) {
            if (component->name != "component") {
                continue;
            }

            // Find their bundle tag
            for (Xml.Node* iter = component->children; iter != null; iter = iter->next) {
                if (iter->name == "bundle") {
                    string bundle_id = iter->get_content ();
                    // If it's not an app, we don't care about sorting it
                    if (!bundle_id.has_prefix ("app/")) {
                        break;
                    }

                    // If it's a stable branch of an app, put it on top of the array
                    if (bundle_id.has_suffix ("/stable")) {
                        sorted_components.insert (0, component);
                    // Otherwise add it to the end
                    } else {
                        sorted_components.add (component);
                    }

                    break;
                }
            }
        }

        // Unlink all of the components we sorted, so we can re-attach them in their new positions
        // Can't do this during the loop above as it breaks the iterator
        foreach (var component in sorted_components) {
            component->unlink ();
        }

        // Re-attach them in the new order
        foreach (var component in sorted_components) {
            root->add_child (component);
        }

        doc->set_compress_mode (7);
        doc->save_file (dest_file.get_path ());

        delete res;
        delete doc;
    }

}
