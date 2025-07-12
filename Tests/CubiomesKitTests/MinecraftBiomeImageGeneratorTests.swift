//
//  MinecraftBiomeImageGeneratorTests.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 12-07-2025.
//

import CryptoKit
import Foundation
import Testing

@testable import CubiomesKit

struct MinecraftBiomeImageGeneratorTests {
    @Test func imageGeneratorMatchesUtils() throws {
        let world = MinecraftWorld(version: MC_NEWEST, seed: 123456)
        var generator = world.generator(in: .nether)
        let rect = MinecraftWorldRect(origin: .zero, scale: MinecraftWorldRect.Size(squaring: 4))

        let cbRange = Cubiomes.Range(
            scale: 4,
            x: rect.origin.x,
            z: rect.origin.z,
            sx: rect.size.length,
            sz: rect.size.width,
            y: rect.origin.y,
            sy: rect.size.height
        )

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
       
        let actualData = MinecraftBiomeImageRenderer.image(
            for: UnsafePointer(biomeIDs),
            using: MinecraftBiomeColorMap.cubiomesDefault(),
            of: rect.size,
            scaledTo: 1,
            flipped: true
        )

        print(expectedData)
        print(actualData)

        let expectedHash = SHA256.hash(data: expectedData)
        let actualHash = SHA256.hash(data: actualData)

        #expect(expectedHash == actualHash)
    }

    
}
