//
//  MinecraftWorldRenderer.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 23-03-2025.
//

import CubiomesInternal
import Foundation

#if canImport(OSLog)
import OSLog
#endif

/// A facility used to render Minecraft worlds as two-dimensional maps.
@MinecraftWorldRendererActor
public class MinecraftWorldRenderer {
    public typealias ColorGroup = (UInt8, UInt8, UInt8)
    public typealias PixelImageData = [CUnsignedChar]

    private var logger = Logger(subsystem: "net.marquiskurt.cubiomeskit", category: "\(MinecraftWorldRenderer.self)")

    /// A structure representing the various options available to the renderer.
    public struct Options: OptionSet, Sendable {
        /// The underlying raw value representing the options selected.
        public let rawValue: Int

        /// Use natural colors for the overworld when rendering the map, instead of the default behavior.
        ///
        /// This color scheme is bundled in CubiomesKit. It aims to represent real Minecraft blocks, providing a more
        /// natural and consistent look with the Minecraft world.
        ///
        /// > SeeAlso: To view the source for the color set, visit
        /// > [https://github.com/Cubitect/biome-colors](https://github.com/Cubitect/biome-colors).
        public static let naturalColors = Options(rawValue: 1 << 0)

        /// Render the map with the position at the center of the image.
        public static let centerPositions = Options(rawValue: 1 << 1)

        /// Create an option set from a raw value.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    private enum Constants {
        static let naturalColormap = "sampled_colormap_optimized"
    }

    var naturalColorFile: String? {
        guard let resourceURL = Bundle.module.url(forResource: Constants.naturalColormap, withExtension: "txt") else {
            logger.warning("The color map doesn't exist in the bundle resources.")
            return nil
        }
        do {
            let data = try Data(contentsOf: resourceURL)
            return String(data: data, encoding: .utf8)
        } catch {
            logger.error("Failed to fetch natural colors: \(error.localizedDescription)")
            return nil
        }
    }

    /// The options configuring this renderer.
    public var options: Options = [.centerPositions]

    var world: MinecraftWorld

    /// Create a renderer for a Minecraft world.
    /// - Parameter world: The Minecraft world the renderer will generate image slices from.
    /// - Parameter options: The options to use in the renderer. Defaults to center positions.
    public init(world: MinecraftWorld, options: Options = [.centerPositions]) {
        self.world = world
        self.options = options
    }

    /// Update the options available to the renderer.
    /// - Parameter options: The options to use in the renderer.
    public func updateOptions(_ options: Options) {
        self.options = options
    }

    /// Render the contents of the world in the specified region.
    /// - Parameter rect: The region to render.
    /// - Parameter pixelsPerCell: The number of pixels that take up an individual block.
    /// - Parameter dimension: The dimension to render the world in.
    public func render(
        inRegion rect: MinecraftWorldRect,
        scale pixelsPerCell: Int32 = 4,
        dimension: MinecraftWorld.Dimension = .overworld
    ) async -> Data {
        let (originX, originZ) = getMapTileOrigin(in: rect, at: pixelsPerCell)
        let renderRect = MinecraftWorldRect(
            origin: MinecraftPoint(x: originX, y: rect.origin.y, z: originZ),
            scale: rect.size,
            mapScale: rect.mapScale)

        let biomeGen = await MinecraftBiomeGenerator(world: world, dimension: dimension)
        let biomeIDs = await biomeGen.generate(for: renderRect)
        let colorMap = getBiomeColorMap(for: dimension)

        let imgWidth = pixelsPerCell * rect.size.length
        let imgHeight = pixelsPerCell * rect.size.width

        let rgbData =
            MinecraftBiomeImageRenderer
            .image(
                for: biomeIDs,
                using: colorMap,
                of: renderRect.size,
                scaledTo: pixelsPerCell,
                flipped: true
            )

        let ppmData = PPMData(pixels: rgbData, size: CGSize(width: Double(imgWidth), height: Double(imgHeight)))
        return Data(ppm: ppmData)
    }

    func getMapTileOrigin(in rect: MinecraftWorldRect, at pixelsPerCell: Int32) -> (Int32, Int32) {
        var originX = rect.origin.x
        var originZ = rect.origin.z
        let size = rect.mapScale.rawValue

        if options.contains(.centerPositions) {
            originX = (originX - (pixelsPerCell * rect.size.length / 2)) / size
            originZ = (originZ - (pixelsPerCell * rect.size.width / 2)) / size
        }
        return (originX, originZ)
    }

    func getBiomeColorMap(for dimension: MinecraftWorld.Dimension) -> MinecraftBiomeColorMap {
        if options.contains(.naturalColors), let naturalColorFile, dimension == .overworld {
            do {
                return try MinecraftBiomeColorMap(decoding: naturalColorFile)
            } catch {
                logger.error("Failed to generate the natural color biome map: \(error.localizedDescription)")
            }
        }
        return .cubiomesDefault()
    }
}
