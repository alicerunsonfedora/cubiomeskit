//
//  MinecraftBiomeImageGeneratorTests.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 12-07-2025.
//

#if canImport(CryptoKit)
import CryptoKit
#endif

import Foundation
import Testing

@testable import CubiomesKitCore

@MinecraftWorldGeneratorActor
struct MinecraftBiomeImageGeneratorTests {
    @Test(.tags(.render))
    func imageGeneratorMatchesUtils() throws {
        let world = MinecraftWorld(version: MC_NEWEST, seed: 123456)
        var generator = world.generator(in: .nether)
        let rect = MinecraftWorldRect(origin: .zero, scale: MinecraftWorldRect.Size(squaring: 4))
        let cbRange = Cubiomes.Range(rect: rect)

        let biomeIDs = allocCache(&generator, cbRange)
        genBiomes(&generator, biomeIDs, cbRange)

        var colorGroup: (UInt8, UInt8, UInt8) = (0, 0, 0)
        initBiomeColors(&colorGroup)

        let imgWidth = rect.size.length
        let imgHeight = rect.size.width

        var expectedData = [CUnsignedChar](repeating: 0, count: Int(3 * imgWidth * imgHeight))
        biomesToImage(
            &expectedData,
            &colorGroup,
            UnsafePointer(
                biomeIDs
            ),
            UInt32(rect.size.length),
            UInt32(rect.size.width),
            1,
            2
        )

        let biomeGenerator = MinecraftBiomeGenerator(world: world, dimension: .nether)
        let semanticIDs = biomeGenerator.generate(for: rect)

        let actualData = MinecraftBiomeImageRenderer.image(
            for: semanticIDs,
            using: MinecraftBiomeColorMap.cubiomesDefault(),
            of: rect.size,
            scaledTo: 1,
            flipped: true
        )

        #if canImport(CryptoKit)
            let expectedHash = SHA256.hash(data: expectedData)
            let actualHash = SHA256.hash(data: actualData)

            #expect(expectedHash == actualHash)
        #else
            #expect(expectedData == actualData)
        #endif
    }


}
