//
//  MinecraftBiomeLUTGeneratorTests.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 30-07-2025.
//

import Testing
@testable import CubiomesKit

struct MinecraftBiomeLUTGeneratorTests {
    @Test(.tags(.render, .biomes))
    func generatorMatchesUpstreamOutput() async throws {
        let rect = MinecraftWorldRect(origin: .zero, scale: MinecraftWorldRect.Size(squaring: 32))
        let cbRange = CubiomesKit.Range(rect: rect)
        let world = MinecraftWorld(version: MC_1_21_WD, seed: 123)

        // NOTE(alicerunsonfedora): Generally, we call allocCache before generating the biomes here. But doing so would
        // make testing that these values match impossible without some pointer shenanigans I refuse to get into.
        var originalGenerator = world.generator()
        let cacheSize = getMinCacheSize(&originalGenerator, cbRange.scale, cbRange.sx, cbRange.sy, cbRange.sz)
        var expected = Array(repeating: Int32(0), count: cacheSize)
        genBiomes(&originalGenerator, &expected, cbRange)

        let biomeGenerator = await MinecraftBiomeGenerator(world: world, dimension: .overworld)
        let actual = await biomeGenerator.generate(for: rect)
        let actualRaw = actual.map(\.rawValue)

        #expect(actualRaw == expected)
    }
}
