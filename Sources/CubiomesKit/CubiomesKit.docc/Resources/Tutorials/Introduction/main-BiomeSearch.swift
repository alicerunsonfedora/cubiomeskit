// The Swift Programming Language
// https://docs.swift.org/swift-book

import CubiomesKit

guard let world = try? MinecraftWorld(version: "1.21 WD", seed: 12345) else {
    print("Err: Can't make the world.")
    exit(1)
}

let myOriginPoint = MinecraftPoint(x: 16, y: 64, z: 16)
let nearestPlains = world.findBiomes(ofType: plains, at: myOriginPoint)

for plain in nearestPlains {
    print("Plains biome at: \(plain.x), \(plain.z)")
}
