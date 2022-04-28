/* objects/categories.vala
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
    public class Categories : Object {
        private static Categories _categories;
        public static unowned Categories get_default () {
            if (_categories == null) {
                _categories = new Categories ();
            }

            return _categories;
        }

        public AppStream.Category accessories;
        public AppStream.Category internet;
        public AppStream.Category games;
        public AppStream.Category develop; 
        public AppStream.Category create;
        public AppStream.Category work;

        construct {
            accessories = get_category ("Accessories", "applications-accessories", {
                "Utility",
                "Monitor",
                "System",
                "Accessibility"
            });
            internet = get_category ("Internet", "applications-internet", {
                "Chat",
                "Email",
                "InstantMessaging",
                "IRCClient",
                "VideoConference",
                "Network",
                "P2P"
            });
            develop = get_category ("Develop", "applications-development", {
                "Database",
                "Debugger",
                "Development",
                "GUIDesigner",
                "IDE",
                "RevisionControl",
                "TerminalEmulator",
                "WebDevelopment"
            });
            games = get_category ("Games", "applications-games", {
                "ActionGame",
                "AdventureGame",
                "ArcadeGame",
                "Amusement",
                "BlocksGame",
                "BoardGame",
                "CardGame",
                "Game",
                "KidsGame",
                "LogicGame",
                "RolePlaying",
                "Shooter",
                "Simulation",
                "SportsGame",
                "StrategyGame"
            });
            create = get_category ("Create", "applications-graphics", {
                "2DGraphics",
                "3DGraphics",
                "Graphics",
                "ImageProcessing",
                "Photography",
                "RasterGraphics",
                "VectorGraphics",
                "AudioVideoEditing",
                "Midi",
                "Mixer",
                "Recorder",
                "Sequencer",
                "ArtificialIntelligence",
                "Astronomy",
                "Biology",
                "Calculator",
                "Chemistry",
                "ComputerScience",
                "DataVisualization",
                "Electricity",
                "Electronics",
                "Engineering",
                "Geology",
                "Geoscience",
                "Math",
                "NumericalAnalysis",
                "Physics",
                "Robotics",
                "Science",
                "TV",
                "Video",
                "Audio",
                "Music"
            });
            work = get_category ("Work", "applications-office", {
                "Chat",
                "ContactManagement",
                "Email",
                "InstantMessaging",
                "IRCClient",
                "Telephony",
                "VideoConference",
                "Economy",
                "Finance",
                "Network",
                "P2P",
                "Office",
                "Presentation",
                "Publishing",
                "Spreadsheet",
                "WordProcessor",
                "Dictionary",
                "Languages",
                "Literature",
                "OCR",
                "TextEditor",
                "TextTools",
                "Translation",
            });
        }

        public AppStream.Category get_category (string name, string icon, string[] groups) {
            var category = new AppStream.Category ();
            category.set_name (name);
            category.set_icon (icon);

            foreach (var group in groups) {
                category.add_desktop_group (group);
            }

            return category;
        }
    }
}
