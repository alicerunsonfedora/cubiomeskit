// The Swift Programming Language
// https://docs.swift.org/swift-book

import CubiomesKit

guard let world = try? MinecraftWorld(version: "1.21 WD", seed: 12345) else {
    print("Err: Can't make the world.")
    exit(1)
}
