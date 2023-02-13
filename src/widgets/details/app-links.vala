/* widgets/details/app-license-links.vala
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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/details/app-links.ui")]
    public class AppLinks : He.Bin {
        [GtkChild]
        private unowned He.MiniContentBlock project_website_row;
        [GtkChild]
        private unowned He.MiniContentBlock translate_row;
        [GtkChild]
        private unowned He.MiniContentBlock report_an_issue_row;
        [GtkChild]
        private unowned He.MiniContentBlock help_row;

        public AppLinks (Core.Package package) {
            Object ();

            var homepage_url = package.component.get_url (AppStream.UrlKind.HOMEPAGE);
            if (homepage_url != null) {
                project_website_row.set_name (homepage_url);
                project_website_row.subtitle = (new Utils ().get_uri_hostname (homepage_url));
                project_website_row.set_visible (true);
            }

            var translate_url = package.component.get_url (AppStream.UrlKind.TRANSLATE);
            if (translate_url != null) {
                translate_row.set_name (translate_url);
                translate_row.subtitle = (new Utils ().get_uri_hostname (translate_url));
                translate_row.set_visible (true);
            }

            var issue_url = package.component.get_url (AppStream.UrlKind.BUGTRACKER);
            if (issue_url != null) {
                report_an_issue_row.set_name (issue_url);
                report_an_issue_row.subtitle = (new Utils ().get_uri_hostname (issue_url));
                report_an_issue_row.set_visible (true);
            }

            var help_url = package.component.get_url (AppStream.UrlKind.HELP);
            if (help_url != null) {
                help_row.set_name (help_url);
                help_row.subtitle = (new Utils ().get_uri_hostname (help_url));
                help_row.set_visible (true);
            }
        }
    }
}
 