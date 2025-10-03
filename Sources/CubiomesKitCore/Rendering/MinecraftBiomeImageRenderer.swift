//
//  WTFIsThisIDK.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 12-07-2025.
//

struct MinecraftBiomeImageRenderer {
    typealias BiomeIDPointer = UnsafePointer<Int32>
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

    static func image(
        for biomes: [MinecraftBiome],
        using colorMap: MinecraftBiomeColorMap,
        of size: MinecraftWorldRect.Size,
        scaledTo pixelsPerCell: Int32,
        flipped: Bool
    ) -> [CUnsignedChar] {
        let imgWidth = UInt32(pixelsPerCell) * UInt32(size.length)
        let imgHeight = UInt32(pixelsPerCell) * UInt32(size.width)
       
        var rgbData = [CUnsignedChar](repeating: 0, count: Int(3 * imgWidth * imgHeight))
        Self.colorizeImageData(
            data: &rgbData,
            colors: colorMap,
            biomeIDs: biomes,
            size: size,
            pixelsPerCell: UInt32(pixelsPerCell),
            flip: flipped
        )
        return rgbData
    }

    @discardableResult
    static func colorizeImageData(
        data: inout [CUnsignedChar],
        colors: MinecraftBiomeColorMap,
        biomeIDs: [MinecraftBiome],
        size: MinecraftWorldRect.Size,
        pixelsPerCell: UInt32,
        flip: Bool
    ) -> Bool {
        var containsInvalidBiomes = false

        for blockZ in 0..<Int(size.width) {
            for blockX in 0..<Int(size.length) {
                let result = biomeColor(
                    at: BlockPosition(x: blockX, z: blockZ),
                    width: Int(size.length),
                    biomeLUT: biomeIDs,
                    colorLUT: colors
                )
                if result.containsInvalidBiomes { containsInvalidBiomes = true }

                for row in 0..<pixelsPerCell {
                    for col in 0..<pixelsPerCell {
                        assignPixel(
                            at: GridCoordinate(row: row, column: col),
                            blockPosition: BlockPosition(x: Int(blockX), z: Int(blockZ)),
                            pixelsPerCell: pixelsPerCell,
                            data: &data,
                            flip: flip,
                            color: result.color,
                            width: UInt32(size.length),
                            height: UInt32(size.width)
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
        biomeLUT: [MinecraftBiome],
        colorLUT: MinecraftBiomeColorMap
    ) -> BiomeColorResult {
        let biomeID = biomeLUT[position.z * width + position.x]
        var result = BiomeColorResult(containsInvalidBiomes: false, color: .black)

        let color = colorLUT.color(for: biomeID)
        result.color = color

        if (0...256).contains(biomeID.rawValue) {
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
