/* core/job.vala
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
    public class Job : Object {
        public Type operation { get; construct; }
        public JobArgs? args { get; set; }
        public Error? error { get; set; }

        public Value result;

        public signal void results_ready ();

        public enum Type {
            REFRESH_CACHE,
            UPDATE_PACKAGE,
            INSTALL_PACKAGE
        }

        public Job (Type type) {
            Object (operation: type);
        }
    }

    public abstract class JobArgs { }

    public class RefreshCacheArgs : JobArgs {
        public Cancellable? cancellable;
    }

    public class UpdatePackageArgs : JobArgs {
        public Package package;
        public ChangeInformation? change_information;
        public Cancellable? cancellable;
    }

    public class InstallPackageArgs : JobArgs {
        public Package package;
        public ChangeInformation? change_information;
        public Cancellable? cancellable;
    }
}
