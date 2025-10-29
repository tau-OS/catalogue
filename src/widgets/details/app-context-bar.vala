/* widgets/details/app-context-bar.vala
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
    [GtkTemplate (ui = "/com/fyralabs/Catalogue/details/app-context-bar.ui")]
    public class AppContextBar : He.Bin {
        [GtkChild]
        private unowned Gtk.Label storage_tile_lozenge_content;
        [GtkChild]
        private unowned Gtk.Label storage_tile_description;

        [GtkChild]
        private unowned Gtk.Box age_rating_tile_lozenge;
        [GtkChild]
        private unowned Gtk.Label age_rating_tile_lozenge_content;
        [GtkChild]
        private unowned Gtk.Label age_rating_tile_description;

        [GtkChild]
        private unowned Gtk.Box lozenge0;
        [GtkChild]
        private unowned Gtk.Box lozenge1;
        [GtkChild]
        private unowned Gtk.Box lozenge2;
        [GtkChild]
        private unowned Gtk.Image lozenge0_image;
        [GtkChild]
        private unowned Gtk.Image lozenge1_image;
        [GtkChild]
        private unowned Gtk.Image lozenge2_image;
        [GtkChild]
        private unowned Gtk.Label license_tile_title;
        [GtkChild]
        private unowned Gtk.Label license_tile_description;

        [GtkCallback]
        public void open_oars_dialog () {
            var window = new He.Window () {
                modal = true
            };
            window.set_transient_for (((Window)new Utils ().find_ancestor_of_type<Window>(this)));
            window.present ();
        }
            
        public AppContextBar (Core.Package package) {
            Object ();

            get_app_download_size.begin (package);

            get_app_license (package);

            package.component.get_content_ratings ().foreach ((rating) => {
                string age_text = "";
                ContentRatingHelper.RatingLozengeClasses css_class = ContentRatingHelper.RatingLozengeClasses.UNKNOWN;
                new ContentRatingHelper ().get_rating_lozenge (rating, out age_text, out css_class);
                age_rating_tile_lozenge_content.set_label (age_text);
                age_rating_tile_description.set_label (new ContentRatingHelper ().format_rating_description (css_class));
                if (css_class == ContentRatingHelper.RatingLozengeClasses.RATING_0) {

                    age_rating_tile_lozenge.add_css_class ("details-rating-0");
                } else if (css_class == ContentRatingHelper.RatingLozengeClasses.RATING_5) {
                    age_rating_tile_lozenge.add_css_class ("details-rating-5");
                } else if (css_class == ContentRatingHelper.RatingLozengeClasses.RATING_12) {
                    age_rating_tile_lozenge.add_css_class ("details-rating-12");
                } else if (css_class == ContentRatingHelper.RatingLozengeClasses.RATING_15) {
                    age_rating_tile_lozenge.add_css_class ("details-rating-15");
                } else if (css_class == ContentRatingHelper.RatingLozengeClasses.RATING_18) {
                    age_rating_tile_lozenge.add_css_class ("details-rating-18");
                } else {
                    age_rating_tile_lozenge.add_css_class ("grey");
                }
            });
        }

        private void get_app_license (Core.Package package) {
            var app_license = package.component.get_project_license ();

            if (app_license != null && AppStream.license_is_free_license (app_license)) {
                license_tile_title.set_label ("Community Built");
                lozenge0_image.set_from_icon_name ("emblem-favorite-symbolic");
                lozenge1_image.set_from_icon_name ("community-symbolic");
                lozenge2_image.set_from_icon_name ("sign-language-symbolic");
                license_tile_description.set_label ("This software is developed in the open by a community of volunteers, and released under the %s license.\n\nYou can contribute and help make it even better.".printf (app_license));
                lozenge0.add_css_class ("green");
                lozenge1.add_css_class ("green");
                lozenge2.add_css_class ("green");
            } else {
                license_tile_title.set_label ("Proprietary");
                lozenge0_image.set_from_icon_name ("warning-symbolic");
                lozenge1_image.set_from_icon_name ("face-sad-symbolic");
                lozenge2_image.set_from_icon_name ("padlock-open-symbolic");
                license_tile_description.set_label ("This software is not developed in the open. It may be harder to tell if this software is insecure.\n\nYou may not be able to contribute or influence development.");
                lozenge0.add_css_class ("red");
                lozenge1.add_css_class ("red");
                lozenge2.add_css_class ("red");
            }
        }

        private async void get_app_download_size (Core.Package package) {
            if (package.state == Core.Package.State.INSTALLED || package.state == Core.Package.State.UPDATE_AVAILABLE) {
                var size = yield package.get_installed_size ();
                string human_size = GLib.format_size (size);
                storage_tile_lozenge_content.set_label (human_size);
                storage_tile_description.set_label ("May use more storage due to dependencies.");
                return;
            }

            var size = yield package.get_download_size_with_deps ();
            string human_size = GLib.format_size (size);
            storage_tile_lozenge_content.set_label (human_size);
            storage_tile_description.set_label ("Needs up to %s of additional system downloads".printf (human_size));

            tooltip_markup = "<b>%s</b>\n%s".printf (
                _("Actual Download Size Likely to Be Smaller"),
                _("Only the parts of apps and updates that are needed will be downloaded.")
            );
            storage_tile_description.set_tooltip_markup (tooltip_markup);
        }
    }
}
