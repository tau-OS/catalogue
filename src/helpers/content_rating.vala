namespace Catalogue {
    public class ContentRatingHelper {
        public enum RatingLozengeClasses {
            RATING_18,
            RATING_15,
            RATING_12,
            RATING_5,
            RATING_0,
            UNKNOWN
        }

        private string format_age_short (AppStream.ContentRatingSystem system, uint age) {
            if (system == AppStream.ContentRatingSystem.ESRB) {
                if (age >= 18)
                    return "AO";
                if (age >= 17)
                    return "M";
                if (age >= 13)
                    return "T";
                if (age >= 10)
                    return "E10+";
                if (age >= 6)
                    return "E";
        
                return "EC";
            }
        
            return system.format_age (age);
        }

        public string format_rating_description (RatingLozengeClasses rating) {
            // yes i stole descriptions from ESRB sorry
            if (rating == RatingLozengeClasses.RATING_18) {
                return "May include prolonged scenes of intense violence, graphic sexual content and/or gambling with real currency.";
            } else if (rating == RatingLozengeClasses.RATING_15) {
                // ok this one is from PEGI
                return "May include the use of tobacco, alcohol or illegal drugs, intense violence, and/or sexual activity.";
            } else if (rating == RatingLozengeClasses.RATING_12) {
                return "May contain violence, suggestive themes, crude humor, minimal blood, simulated gambling and/or infrequent use of strong language.";
            } else if (rating == RatingLozengeClasses.RATING_5) {
                return "May contain cartoon, fantasy or mild violence, and/or scenes that may be frightening to younger users.";
            } else if (rating == RATING_0) {
                return "Appropriate for all ages.";
            } else {
                return "Unknown age rating. You may view more details by clicking this tile.";
            }
        }

        public void get_rating_lozenge (
            AppStream.ContentRating? content_rating,
            out string? age_text,
            out RatingLozengeClasses? css_class
        ) {
            uint age = 0;
            age_text = null;
            css_class = null;

            var locale = Intl.setlocale (LocaleCategory.MESSAGES, "");
            var system = AppStream.ContentRatingSystem.from_locale (locale);
            debug ("Content rating system is guessed as %s from %s",
                    system.to_string (),
                    locale);
            
            if (content_rating != null) {
                age = content_rating.get_minimum_age ();
            }

            if (age != uint.MAX) {
                age_text = format_age_short (system, age);
            }

            // Some ratings systems (PEGI) don’t start at age 0
            if (content_rating != null && age_text == null && age == 0) {
                age_text = "All";
            }

            // We only support OARS
            if (age_text == null ||
                (content_rating != null &&
                    strcmp (content_rating.get_kind (), "oars-1.0") != 0 &&
                    strcmp (content_rating.get_kind (), "oars-1.1") != 0 )) {
                // App has no age rating information
                age_text = "?";
                css_class = RatingLozengeClasses.UNKNOWN;
            } else {
                if (age >= 18) {
                    css_class = RatingLozengeClasses.RATING_18;
                } else if (age >= 15) {
                    css_class = RatingLozengeClasses.RATING_15;
                } else if (age >= 12) {
                    css_class = RatingLozengeClasses.RATING_12;
                } else if (age >= 5) {
                    css_class = RatingLozengeClasses.RATING_5;
                } else {
                    css_class = RatingLozengeClasses.RATING_0;
                }
            }
        }
    }
}
