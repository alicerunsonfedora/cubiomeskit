//
//  MinecraftBiomeLUTGenerator.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 30-07-2025.
//

import CubiomesInternal

/// An actor used to handle Minecraft world generation.
@globalActor actor MinecraftWorldGeneratorActor {
    /// The shared instance of the generation actor.
    static let shared = MinecraftWorldGeneratorActor()
}

@MinecraftWorldGeneratorActor
class MinecraftBiomeLUTGenerator {
    var world: MinecraftWorld
    var dimension: MinecraftWorld.Dimension

    init(world: MinecraftWorld, dimension: MinecraftWorld.Dimension) {
        self.world = world
        self.dimension = dimension
    }

    func generate(for rect: MinecraftWorldRect) -> [MinecraftBiome] {
        var generator = world.generator(in: dimension)
        let cbRange = CubiomesInternal.Range(rect: rect)
        let cacheSize = getMinCacheSize(&generator, cbRange.scale, cbRange.sx, cbRange.sy, cbRange.sz)
        var lookupTable = Array(repeating: Int32(0), count: cacheSize)
        genBiomes(&generator, &lookupTable, cbRange)
        return lookupTable.map(MinecraftBiome.init(rawValue:))
    }
}
