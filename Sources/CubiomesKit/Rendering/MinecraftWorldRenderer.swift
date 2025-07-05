//
//  MinecraftWorldRenderer.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 23-03-2025.
//

import CubiomesInternal
import Foundation

/// A facility used to render Minecraft worlds as two-dimensional maps.
@MinecraftWorldRendererActor
public class MinecraftWorldRenderer {
    public typealias ColorGroup = (UInt8, UInt8, UInt8)
    public typealias PixelImageData = [CUnsignedChar]
    
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
            return nil
        }
        do {
            let data = try Data(contentsOf: resourceURL)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to fetch natural colors: \(error.localizedDescription)")
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

    /// Renders a world region as raw image data.
    /// - Parameter rect: The region to render in the world.
    /// - Parameter pixelsPerCell: The number of pixels that occupy a single cell in the rendered image.
    /// - Parameter dimension: The dimension to render the region in.
    public func render(
        inRegion rect: MinecraftWorldRect,
        scale pixelsPerCell: Int32 = 4,
        dimension: MinecraftWorld.Dimension = .overworld
    ) async -> Data {
        var generator = world.generator(in: dimension)
        var originX = rect.origin.x
        var originZ = rect.origin.z
        let size = rect.mapScale.rawValue

        if options.contains(.centerPositions) {
            originX = (originX - (pixelsPerCell * rect.size.length / 2)) / size
            originZ = (originZ - (pixelsPerCell * rect.size.width / 2)) / size
        }
        
        let _range = Cubiomes.Range(
            scale: size,
            x: originX,
            z: originZ,
            sx: rect.size.length,
            sz: rect.size.width,
            y: rect.origin.y,
            sy: rect.size.height
        )

        let biomeIds = allocCache(&generator, _range)
        genBiomes(&generator, biomeIds, _range)

        var biomeColors: ColorGroup = (0, 0, 0)
        if options.contains(.naturalColors), let naturalColorFile, dimension == .overworld {
            parseBiomeColors(&biomeColors, naturalColorFile)
        } else {
            initBiomeColors(&biomeColors)
        }
       
        // TODO: WTF does it crash whenever we pass UInt32(pixelsPerCell) for ppc in this call? Why overflow?
        // Has I ever?
        let rgbData = await generateImageData(
            imgWidth: 1024,
            imgHeight: 1024,
            biomeColors: &biomeColors,
            biomeIds: biomeIds,
            scaleX: 256,
            scaleZ: 256,
            pixelsPerCell: 4
        )

        let ppmData = PPMData(pixels: rgbData, size: CGSize(width: Double(1024), height: Double(1024)))
        return Data(ppm: ppmData)
    }
    
    // NOTE(alicerunsonfedora): We're passing ownership of biomeIds here. While this makes Cubiomes happy (right now),
    // this might cause some Swift concurrency issues because of it. Must investigate (caller shouldn't do anything else
    // with biomeIds).
    func generateImageData(
        imgWidth: Int32,
        imgHeight: Int32,
        biomeColors: inout ColorGroup,
        biomeIds: UnsafeMutablePointer<Int32>?,
        scaleX: UInt32,
        scaleZ: UInt32,
        pixelsPerCell: UInt32
    ) async -> PixelImageData {
        var rgbData = PixelImageData(repeating: 0, count: Int(3 * imgWidth * imgHeight))
        
        // TODO: What if... we write our own??? We could replace this and see if we can chunk it on our own.
        biomesToImage(
            &rgbData,
            &biomeColors,
            UnsafePointer(biomeIds),
            scaleX,
            scaleZ,
            pixelsPerCell,
            2
        )
        
        // TODO: Check this is where this should occur. It very likely does...
        biomeIds?.deallocate()
        return rgbData
    }
}
