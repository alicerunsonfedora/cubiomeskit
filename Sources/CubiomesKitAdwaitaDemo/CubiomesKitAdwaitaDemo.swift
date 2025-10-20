import Adwaita
import CubiomesKit

@main
struct CubiomesKitAdwaitaDemo: App {
    let app = AdwaitaApp(id: "dev.alidade.cubiomeskit.adwaita-demo")

    var scene: Scene {
        Window(id: "main") { window in
            MinecraftMap()
                .topToolbar {
                    MainToolbar(app: app, window: window)
                }
                .topBarStyle(.raised)
        }
    }
}
