//
//  BiomeColor.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 10-07-2025.
//

import Foundation

struct ColorRGB: Sendable, Equatable {
    enum ParseError: Error, Equatable {
        case invalidHexHeader
        case invalidColorLength
        case noScannedValue
    }
    var red: UInt8
    var green: UInt8
    var blue: UInt8

    init(r: UInt8, g: UInt8, b: UInt8) {
        self.red = r
        self.blue = b
        self.green = g
    }

    init(hexValue: UInt64) {
        let colorR = (hexValue >> 16 & 0xFF)    // 0xFF0000
        let colorG = (hexValue >> 8 & 0xFF)     // 0x00FF00
        let colorB = (hexValue & 0xFF)          // 0x0000FF
        
        red = UInt8(colorR)
        green = UInt8(colorG)
        blue = UInt8(colorB)
    }

    init(hex: String) throws(ParseError) {
        guard hex.starts(with: "#") else { throw .invalidHexHeader }
        let startIndex = hex.index(after: hex.startIndex)
        let colorValues = String(hex[startIndex...])
        guard colorValues.count == 6 else { throw .invalidColorLength }

        let scanner = Scanner(string: colorValues)
        var hexValue: UInt64 = 0
        guard scanner.scanHexInt64(&hexValue) else { throw .noScannedValue }

        self.init(hexValue: hexValue)
    }
}

extension ColorRGB {
    static let black = ColorRGB(r: 0, g: 0, b: 0)
}
