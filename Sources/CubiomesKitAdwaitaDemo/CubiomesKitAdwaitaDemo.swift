#if Adwaita

import Adwaita
import CubiomesKit

@main
struct CubiomesKitAdwaitaDemo: App {
    let app = AdwaitaApp(id: "dev.alidade.cubiomeskit.adwaita-demo")

    var scene: Scene {
        Window(id: "main") { window in
            MinecraftMap(world: try! MinecraftWorld(version: "1.21", seed: 123))
                .frame(minWidth: 640, minHeight: 480)
                .topToolbar {
                    MainToolbar(app: app, window: window)
                }
                .topBarStyle(.raised)
        }
        .defaultSize(width: 800, height: 600)
    }
}

#endif
