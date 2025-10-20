#if Adwaita

import Adwaita

struct MainToolbar: View {
    @State private var about = false
    var app: AdwaitaApp
    var window: AdwaitaWindow


    var view: Body {
   	    HeaderBar.end {
            Menu(icon: .default(icon: .openMenu)) {
                MenuButton("New Window", window: false) {
                    app.addWindow("main")
                }
                .keyboardShortcut("n".ctrl())
                MenuButton("Close Window") {
                    window.close()
                }
                .keyboardShortcut("w".ctrl())
                MenuSection {
                    MenuButton("About CubiomesKit Adwaita Demo", window: false) {
                        about = true
                    }
                }
            }
            .primary()
            .tooltip("Main Menu")
            .aboutDialog(
                visible: $about,
                app: "CubiomesKit Adwaita Demo",
                developer: "CubiomesKit Team",
                version: "dev",
                website: .init(string: "https://source.marquiskurt.net/AlidadeMC/CubiomesKit")!,
                issues: .init(string: "https://youtrack.marquiskurt.net/youtrack/issues/CBK")!
            )
        }
        .headerBarTitle {
            WindowTitle(subtitle: "", title: "CubiomesKit Adwaita Demo")
        }
    }
}

#endif
