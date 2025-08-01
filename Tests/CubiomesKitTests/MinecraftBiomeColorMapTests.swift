//
//  MinecraftBiomeColorMapTests.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 09-07-2025.
//

import Foundation
import Testing

@testable import CubiomesKit

struct MinecraftBiomeColorMapTests {
    @Test(.tags(.render))
    func biomeColorParses() async throws {
        let color = try ColorRGB(hex: "#000000")
        #expect(color == ColorRGB(r: 0, g: 0, b: 0))

        let magicColor = try ColorRGB(hex: "#F1C287")
        #expect(magicColor == ColorRGB(r: 241, g: 194, b: 135))

        let magicColorRaw = ColorRGB(hexValue: 0xf1c287)
        #expect(magicColorRaw == ColorRGB(r: 241, g: 194, b: 135))
    }

    @Test(.tags(.render))
    func biomeColorParseFailures() async throws {
        #expect(throws: ColorRGB.ParseError.invalidHexHeader) {
            try ColorRGB(hex: "lorelei")
        }
        
        #expect(throws: ColorRGB.ParseError.invalidColorLength) {
            try ColorRGB(hex: "#00000000")
        }
    }

    @Test(.tags(.render))
    func biomeMapInit() async throws {
        let biomeMap = try MinecraftBiomeColorMap(
            decoding:
                """
                badlands #ba6322
                badlands_plateau #9f5d3e
                bamboo_jungle #3f5e03 
                """
        )

        #expect(biomeMap.color(for: badlands) == ColorRGB(r: 186, g: 99, b: 34))
        #expect(biomeMap.color(for: bamboo_jungle) == ColorRGB(r: 63, g: 94, b: 3))
        #expect(biomeMap.color(for: taigaHills) == .black)
    }

    @Test(.tags(.render))
    func biomeMapParseFailure() async throws {
        #expect(throws: MinecraftBiomeColorMap.DecodeError.invalidBiomeID) {
            try MinecraftBiomeColorMap(
                decoding:
                    """
                    lorelei #C82B7B
                    """
            )
        }
        #expect(throws: MinecraftBiomeColorMap.DecodeError.invalidLineArguments) {
            try MinecraftBiomeColorMap(decoding: " ")
        }
        #expect(throws: MinecraftBiomeColorMap.DecodeError.invalidColorCode(.invalidHexHeader)) {
            try MinecraftBiomeColorMap(decoding: "badlands lorelei")
        }
    }

    @Test(.tags(.render))
    func biomeMapCubiomesDefault() async throws {
        let biomeMap = MinecraftBiomeColorMap.cubiomesDefault()
        #expect(!biomeMap.isEmpty)
    }
}
