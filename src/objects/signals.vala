/* objects/signals.vala
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

public class Signals : GLib.Object {
    private static Signals _signals;
    public static unowned Signals get_default () {
        if (_signals == null) {
            _signals = new Signals ();
        }

        return _signals;
    }

    public signal void window_do_back_button_clicked (bool is_album);

    public signal void updates_progress_bar_change (Catalogue.Core.Package package, bool is_finished);
}
