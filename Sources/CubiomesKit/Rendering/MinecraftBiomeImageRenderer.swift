//
//  WTFIsThisIDK.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 12-07-2025.
//

struct MinecraftBiomeImageRenderer {
    struct BiomeColorResult {
        var containsInvalidBiomes: Bool
        var color: ColorRGB
    }

    private struct GridCoordinate {
        var row: UInt32
        var column: UInt32
    }

    private struct BlockPosition {
        var x: Int
        var z: Int
    }

    @discardableResult
    static func applesauce(
        data: inout [CUnsignedChar],
        colors: MinecraftBiomeColorMap,
        biomeIDs: UnsafePointer<Int32>!,
        width: UInt32,
        height: UInt32,
        pixelsPerCell: UInt32,
        flip: Bool
    ) -> Bool {
        var containsInvalidBiomes = false

        for blockZ in 0..<Int(height) {
            for blockX in 0..<Int(width) {
                let result = biomeColor(
                    at: BlockPosition(x: blockX, z: blockZ),
                    width: Int(width),
                    biomeLUT: biomeIDs,
                    colorLUT: colors
                )
                if result.containsInvalidBiomes { containsInvalidBiomes = true }

                for row in 0..<pixelsPerCell {
                    for col in 0..<pixelsPerCell {
                        assignPixel(
                            at: GridCoordinate(row: row, column: col),
                            blockPosition: BlockPosition(x: blockX, z: blockZ),
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

    private static func biomeColor(
        at position: BlockPosition,
        width: Int,
        biomeLUT: UnsafePointer<Int32>!,
        colorLUT: MinecraftBiomeColorMap
    ) -> BiomeColorResult {
        let biomeID = biomeLUT[position.z * width + position.x]
        var result = BiomeColorResult(containsInvalidBiomes: false, color: .black)

        let color = colorLUT.color(for: MinecraftBiome(biomeID))
        result.color = color

        if (0...256).contains(biomeID) {
            return result
        }

        // This may happen for some intermediate layers
        result.containsInvalidBiomes = true
        return result
    }

    private static func assignPixel(
        at coordinate: GridCoordinate,
        blockPosition: BlockPosition,
        pixelsPerCell: UInt32,
        data: inout [CUnsignedChar],
        flip: Bool,
        color: ColorRGB,
        width: UInt32,
        height: UInt32
    ) {
        let col = coordinate.column
        let row = coordinate.row
        let blockX = UInt32(blockPosition.x)
        let blockZ = UInt32(blockPosition.z)

        var pixelIndex = pixelsPerCell * blockX + col
        if flip {
            pixelIndex += (width * pixelsPerCell) * ((pixelsPerCell * blockZ) + row)
        } else {
            pixelIndex +=
                (width * pixelsPerCell) * ((pixelsPerCell * (height - 1 - blockZ)) + row)
        }
        data[(3 * Int(pixelIndex))] = color.red
        data[(3 * Int(pixelIndex)) + 1] = color.green
        data[(3 * Int(pixelIndex)) + 2] = color.blue
    }
}
