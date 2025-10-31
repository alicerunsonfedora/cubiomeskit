import CubiomesKit
import SwiftUI

struct HermitcraftMap: View {
    @State private var world: MinecraftWorld?
    
    var body: some View {
        Group {
            if let world {
                MinecraftMap(world: world)
                    .ignoresSafeArea()
            } else {
                ContentUnavailableView(
                    "Welcome to Hermitcraft",
                    systemImage: "globe")
                .navigationTitle("Hermitcraft")
            }
        }
        .onAppear {
            loadHermitcraftWorld()
        }
    }

    private func loadHermitcraftWorld() {
        do {
            world = try MinecraftWorld(version: "1.20", seed: Int64(HermitcraftWorld.seed))
        } catch {
            print("Failed to load the world: \(error.localizedDescription)")
        }
    }
}
