//
//  WTFIsThisIDK.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 12-07-2025.
//

struct MinecraftBiomeImageRenderer {
    struct BiomeColorResult {
        var containsInvalidBiomes: Bool
        var color: (UInt8, UInt8, UInt8)
    }

    @discardableResult
    static func applesauce(
        data: inout [CUnsignedChar],
        colors: UnsafeMutablePointer<(UInt8, UInt8, UInt8)>!,
        biomeIDs: UnsafePointer<Int32>!,
        width: UInt32,
        height: UInt32,
        pixelsPerCell: UInt32,
        flip: Bool
    ) -> Bool {
        //        int biomesToImage(
        //                unsigned char *pixels, <-- data
        //                unsigned char biomeColors[256][3], <-- colors
        //                const int *biomes, <-- biomeIDs
        //                const unsigned int sx, <-- width
        //                const unsigned int sy, <-- height
        //                const unsigned int pixscale, <-- pixelsPerCell
        //                const int flip <-- flip
        //        ) {

        var containsInvalidBiomes = false

        for blockZ in 0..<Int(height) {
            for blockX in 0..<Int(width) {
                let result = biomeColor(
                    blockX: blockX,
                    blockZ: blockZ,
                    width: Int(width),
                    biomeLUT: biomeIDs,
                    colorLUT: colors
                )
                if result.containsInvalidBiomes { containsInvalidBiomes = true }

                for row in 0..<pixelsPerCell {
                    for col in 0..<pixelsPerCell {
                        assignPixel(
                            row: row,
                            col: col,
                            blockX: UInt32(blockX),
                            blockZ: UInt32(blockZ),
                            pixelsPerCell: pixelsPerCell,
                            data: &data,
                            flip: flip,
                            color: result.color,
                            width: width,
                            height: height
                        )
                    }
                }
            }
        }
        return containsInvalidBiomes
    }

    static func biomeColor(
        blockX: Int,
        blockZ: Int,
        width: Int,
        biomeLUT: UnsafePointer<Int32>!,
        colorLUT: UnsafeMutablePointer<(UInt8, UInt8, UInt8)>!
    ) -> BiomeColorResult {
        let biomeID = biomeLUT[blockZ * width + blockX]
        var result = BiomeColorResult(containsInvalidBiomes: false, color: (0, 0, 0))

        if (0...256).contains(biomeID) {
            result.color = colorLUT[Int(biomeID)]
        } else {
            // This may happen for some intermediate layers
            result.containsInvalidBiomes = true
            var (r, g, b) = colorLUT[Int(biomeID & 0x7f)]
            r -= 40
            g -= 40
            b -= 40

            r = r > 255 ? 0 : r & 255
            g = g > 255 ? 0 : g & 255
            b = b > 255 ? 0 : b & 255
            result.color = (r, g, b)
        }
        return result
    }

    static func assignPixel(
        row: UInt32,
        col: UInt32,
        blockX: UInt32,
        blockZ: UInt32,
        pixelsPerCell: UInt32,
        data: inout [CUnsignedChar],
        flip: Bool,
        color: (UInt8, UInt8, UInt8),
        width: UInt32,
        height: UInt32
    ) {
        let (r, g, b) = color
        var pixelIndex = pixelsPerCell * blockX + col
        if flip {
            pixelIndex += (width * pixelsPerCell) * ((pixelsPerCell * blockZ) + row)
        } else {
            pixelIndex +=
                (width * pixelsPerCell) * ((pixelsPerCell * (height - 1 - blockZ)) + row)
        }
        data[(3 * Int(pixelIndex))] = r
        data[(3 * Int(pixelIndex)) + 1] = g
        data[(3 * Int(pixelIndex)) + 2] = b
    }
}
