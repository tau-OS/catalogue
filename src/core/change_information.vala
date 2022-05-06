/* core/change_information.vala
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
    public class ChangeInformation : Object {
        public enum Status {
            UNKNOWN
        }

        public signal void status_changed ();

        public Gee.MultiMap<unowned FlatpakBackend, string> updatable_packages { public get; private set; }
        public Status status { public get; private set; default=Status.UNKNOWN; }
        public uint64 size;

        construct {
            updatable_packages = new Gee.HashMultiMap<unowned FlatpakBackend, string> ();
            size = 0;
        }

        public bool has_changes () {
            return updatable_packages.size > 0;
        }

        public void clear_update_info () {
            updatable_packages.clear ();
            size = 0;
        }
    }
}
