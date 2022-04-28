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
