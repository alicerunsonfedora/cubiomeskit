#if canImport(AppKit)
    import AppKit
#endif

import CubiomesKit
import Foundation

// The seed used in Hermitcraft Season 10.
// Source: https://www.reddit.com/r/HermitCraft/comments/1ahuli4/hermitcraft_s10_world_info/
private let hermitcraftSeasonTen: Int64 = 5103687417315433447

var world: MinecraftWorld
do {
    world = try MinecraftWorld(version: "1.20", seed: hermitcraftSeasonTen)
} catch {
    print("Error: Failed to instantiate world.")
    print(error.localizedDescription)
    exit(1)
}

// MARK: - Tile rendering goes here!

let origin = MinecraftPoint(x: -100, y: 64, z: -100)
let size = MinecraftWorldRect.Size(squaring: 512)
let region = MinecraftWorldRect(origin: origin, scale: size)

let renderer = await MinecraftWorldRenderer(world: world)
let mapTile = await renderer.render(inRegion: region)

// MARK: - Saving tile to disk.
...
