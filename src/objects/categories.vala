namespace Catalogue {
    public class Categories : Object {
        private static Categories _categories;
        public static unowned Categories get_default () {
            if (_categories == null) {
                _categories = new Categories ();
            }

            return _categories;
        }

        public AppStream.Category games;
        public AppStream.Category develop; 
        public AppStream.Category create;
        public AppStream.Category work;
        public AppStream.Category apps;

        construct {
            games = get_category ("Games", "applications-games-symbolic", {
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
            develop = get_category ("Develop", "application-x-addon-symbolic", {
                "Database",
                "Debugger",
                "Development",
                "GUIDesigner",
                "IDE",
                "RevisionControl",
                "TerminalEmulator",
                "WebDevelopment"
            });
            create = get_category ("Create", "applications-graphics-symbolic", {
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
            });
            work = get_category ("Work", "mail-send-symbolic", {
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
            apps = get_category ("Apps", "view-grid-symbolic", {
                "Security",
                "Tuner",
                "TV",
                "Video",
                "Monitor",
                "System",
                "Education",
                "Utility",
                "Audio",
                "Music"
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
