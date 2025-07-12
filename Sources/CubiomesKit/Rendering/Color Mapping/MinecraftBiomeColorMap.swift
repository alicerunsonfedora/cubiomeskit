//
//  MinecraftBiomeColorMap.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 09-07-2025.
//

import CubiomesInternal

struct MinecraftBiomeColorMap {
    enum DecodeError: Error, Equatable {
        case invalidLineArguments
        case invalidBiomeID
        case invalidColorCode(ColorRGB.ParseError)
    }
    fileprivate var biomeLUT = [MinecraftBiome: ColorRGB]()

    init(prefilling data: [MinecraftBiome: ColorRGB]? = nil) {
        biomeLUT = data ?? [:]
    }

    init(decoding map: String) throws(DecodeError) {
        biomeLUT = [:]
        let lines = map.components(separatedBy: "\n").filter { !$0.isEmpty }
        for line in lines {
            let components = line.components(separatedBy: " ").filter { !$0.isEmpty }
            guard let biomeName = components.first, let biomeColor = components.last else {
                throw .invalidLineArguments
            }

            guard let biomeID = MinecraftBiome(biomeName, minecraftVersion: MC_NEWEST) else {
                throw .invalidBiomeID
            }

            do {
                let color = try ColorRGB(hex: biomeColor)
                biomeLUT[biomeID] = color
            } catch {
                throw .invalidColorCode(error)
            }
        }
    }

    mutating func set(_ color: ColorRGB, for biomeID: MinecraftBiome) {
        biomeLUT[biomeID] = color
    }

    mutating func set(_ hexValue: UInt64, for biomeID: MinecraftBiome) {
        biomeLUT[biomeID] = ColorRGB(hexValue: hexValue)
    }

    func color(for biomeID: MinecraftBiome) -> ColorRGB {
        biomeLUT[biomeID, default: .black]
    }
}

extension MinecraftBiomeColorMap: Collection {
    typealias Element = (MinecraftBiome, ColorRGB)
    typealias Index = Dictionary<MinecraftBiome, ColorRGB>.Index

    var startIndex: Index { biomeLUT.startIndex }
    var endIndex: Index { biomeLUT.endIndex }

    func index(after index: Index) -> Index {
        biomeLUT.index(after: index)
    }

    subscript(position: Index) -> (MinecraftBiome, ColorRGB) {
        biomeLUT[position]
    }
}
