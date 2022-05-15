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
            UNKNOWN,
            CANCELLED,
            WAITING,
            FINISHED
        }

        public signal void status_changed ();
        public signal void progress_changed ();

        public Gee.MultiMap<unowned FlatpakBackend, string> updatable_packages { public get; private set; }
        public bool can_cancel { public get; private set; default=true; }
        public double progress { public get; private set; default=0.0f; }
        public Status status { public get; private set; default=Status.UNKNOWN; }
        public string status_description { public get; private set; default="Waiting"; }
        public uint64 size;

        construct {
            updatable_packages = new Gee.HashMultiMap<unowned FlatpakBackend, string> ();
            size = 0;
        }

        public bool has_changes () {
            return updatable_packages.size > 0;
        }

        public void start () {
            progress = 0.0f;
            status = Status.WAITING;
            status_description = "Waiting";
            status_changed ();
            progress_changed ();
        }
    
        public void complete () {
            status = Status.FINISHED;
            status_description = "Finished";
            status_changed ();
            reset_progress ();
        }
    
        public void cancel () {
            progress = 0.0f;
            status = Status.CANCELLED;
            status_description = "Cancelling";
            reset_progress ();
            status_changed ();
            progress_changed ();
        }

        public void clear_update_info () {
            updatable_packages.clear ();
            size = 0;
        }

        public void reset_progress () {
            status = Status.UNKNOWN;
            status_description = "Starting";
            progress = 0.0f;
        }

        public void callback (bool can_cancel, string status_description, double progress, Status status) {
            if (this.can_cancel != can_cancel || this.status_description != status_description || this.status != status) {
                this.can_cancel = can_cancel;
                this.status_description = status_description;
                this.status = status;
                status_changed ();
            }
    
            if (this.progress != progress) {
                this.progress = progress;
                progress_changed ();
            }
        }
    }
}
