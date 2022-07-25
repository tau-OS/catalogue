/* macros.rs
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
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#[macro_export]
macro_rules! action {
    ($actions_group:expr, $name:expr, $callback:expr) => {{
        let simple_action = gio::SimpleAction::new($name, None);
        simple_action.connect_activate($callback);
        $actions_group.add_action(&simple_action);
    }};
    ($actions_group:expr, $name:expr, $param_type:expr, $callback:expr) => {{
        let simple_action = gio::SimpleAction::new($name, $param_type);
        simple_action.connect_activate($callback);
        $actions_group.add_action(&simple_action);
    }};
}
