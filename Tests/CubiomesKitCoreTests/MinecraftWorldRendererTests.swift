//
//  MinecraftWorldRendererTests.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 05-04-2025.
//

#if canImport(CryptoKit)
import CryptoKit
#endif

import Foundation
import Testing

@testable import CubiomesKitCore

struct MinecraftWorldRendererTests {
    @Test(.tags(.render, .biomes))
    func snapshotMatchesOriginalImage() async throws {
        guard
            let originalDataURL = Bundle.module.url(
                forResource: "snapshotMatchesOriginalImage",
                withExtension: "1"
            )
        else {
            Issue.record("Original snapshot file is missing!")
            return
        }
        let originalData = try Data(contentsOf: originalDataURL)
        let mcWorld = try MinecraftWorld(version: "1.21", seed: 3_257_840_388_504_953_787)
        let renderer = await MinecraftWorldRenderer(world: mcWorld, options: [.centerPositions])
        let data = await renderer.render(
            inRegion: .init(
                origin: .init(x: 116, y: 15, z: -31),
                scale: .init(length: 256, width: 256, height: 1)),
            dimension: .overworld)

        #if canImport(CryptoKit)
            let expectedHash = SHA256.hash(data: originalData)
            let actualHash = SHA256.hash(data: data)
            #expect(actualHash == expectedHash)
        #else
            #expect(data == originalData)
        #endif

        #if swift(>=6.2)
        Attachment.record(originalData, named: "original.ppm")
        Attachment.record(data, named: "actual.ppm")
        #endif
    }

    @MinecraftWorldRendererActor
    @Test(.tags(.render, .biomes))
    func naturalColorsLoads() async throws {
        let mcWorld = try MinecraftWorld(version: "1.21", seed: 3_257_840_388_504_953_787)
        let renderer = MinecraftWorldRenderer(world: mcWorld)
        #expect(renderer.naturalColorFile != nil)
    }
}
