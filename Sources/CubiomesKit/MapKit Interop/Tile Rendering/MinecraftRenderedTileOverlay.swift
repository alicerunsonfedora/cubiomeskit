//
//  MinecraftRenderedTileOverlay.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 03-04-2025.
//

import CachingMapKitTileOverlay
import MapKit
import os

final class MinecraftRenderedTileOverlay: MKTileOverlay, MinecraftTileOverlay {
    struct Configuration: Sendable, Equatable {
        var world: MinecraftWorld
        var dimension: MinecraftWorld.Dimension = .overworld
        var renderingOptions: MinecraftWorldRenderer.Options = []

        static func == (lhs: Configuration, rhs: Configuration) -> Bool {
            lhs.dimension == rhs.dimension && lhs.renderingOptions == rhs.renderingOptions
        }
    }

    enum Constants {
        // NOTE(alicerunsonfedora): This needs to be a power of 2!

        static let minBoundary = -33_554_432  // -29_999_984 is world border
        static let maxBoundary = 33_554_432  // 29_999_984 is world border
    }

    var configuration: Configuration {
        didSet {
            didChangeConfiguration(from: oldValue)
        }
    }

    var ephemeral: Bool = false {
        didSet { didChangeEphemeralRendering() }
    }

    @available(*, deprecated, renamed: "configuration.world")
    var world: MinecraftWorld {
        get { configuration.world }
        set { configuration.world = newValue }
    }

    @available(*, deprecated, renamed: "configuration.dimension")
    var dimension: MinecraftWorld.Dimension {
        get { configuration.dimension }
        set { configuration.dimension = newValue }
    }

    @available(*, deprecated, renamed: "configuration.renderingOptions")
    var renderingOptions: MinecraftWorldRenderer.Options {
        get { configuration.renderingOptions }
        set { configuration.renderingOptions = newValue }
    }

    let cache: TileCache
    let logger: Logger

    init(withConfiguration configuration: Configuration) {
        self.configuration = configuration
        self.cache = TileCache(max: 1000)
        self.logger = Logger(subsystem: "net.marquiskurt.cubiomeskit", category: "\(MinecraftRenderedTileOverlay.self)")

        super.init(urlTemplate: nil)
        self.canReplaceMapContent = true
    }

    @MainActor
    convenience init(world: MinecraftWorld, dimension: MinecraftWorld.Dimension = .overworld) {
        self.init(withConfiguration: Configuration(world: world, dimension: dimension))
    }

    @MainActor
    override func loadTile(at path: MKTileOverlayPath) async throws -> Data {
        let chunk = chunk(forOverlayPath: path)

        if !ephemeral, let data = cache.getValue(forPath: path, in: configuration.dimension) {
            logger.debug(
                "🗺️ Tile cache hit for path (\(TileCache.key(forPath: path, in: self.configuration.dimension)))")
            return data
        }

        if ephemeral {
            logger.warning("🗺️ Tile renderer is ephemeral, which will always generate new tiles.")
        } else {
            logger.debug(
                "🗺️ Tile cache miss for path (\(TileCache.key(forPath: path, in: self.configuration.dimension)))")
        }

        let renderer = await MinecraftWorldRenderer(world: configuration.world, options: configuration.renderingOptions)
        let data = await renderer.render(inRegion: chunk, scale: 1, dimension: configuration.dimension)

        if !ephemeral { cache.set(data, forPath: path, in: configuration.dimension) }
        return data
    }

    func chunk(forOverlayPath path: MKTileOverlayPath) -> MinecraftWorldRect {
        var posX = Int32(Constants.minBoundary)
        var posZ = Int32(Constants.minBoundary)

        let totalTilesOnAxis = (1 << path.z)
        let span = Constants.maxBoundary - Constants.minBoundary

        let blockPerTile = span / totalTilesOnAxis
        posX += Int32(blockPerTile * path.x)
        posZ += Int32(blockPerTile * path.y)

        let chunk = MinecraftWorldRect(
            origin: MinecraftPoint(x: posX, y: Self.getYLevels(for: configuration.dimension), z: posZ),
            scale: MinecraftWorldRect.Size(squaring: Int32(blockPerTile))
        )

        logger.debug("🗺️ Mapping at current scale: 🔳 \(totalTilesOnAxis), 🧱 \(blockPerTile)")
        logger.debug(
            "🗺️ [\(path.x), \(path.y) @ \(path.z)] -> 🍱 [\(chunk.origin.x), \(chunk.origin.z) @ \(blockPerTile)]"
        )
        return chunk
    }

    private static func getYLevels(for dimension: MinecraftWorld.Dimension) -> Int32 {
        // NOTE: Values pulled from the specified levels at: https://minecraft.wiki/w/Altitude.
        switch dimension {
        case .overworld:
            // Sea level for the overworld
            return 62
        case .nether:
            // Lava sea level in the Nether
            return 31
        case .end:
            // Where the End platform generates
            return 48
        }
    }

    private func didChangeEphemeralRendering() {
        guard self.ephemeral else {
            return
        }
        flushCache()
    }

    private func didChangeConfiguration(from oldValue: Configuration) {
        if configuration == oldValue {
            return
        }
        logger.debug("🗺️ The world dimension or the rendering options have changed. The cache must be flushed.")
        flushCache()
    }

    private func flushCache() {
        logger.debug("🗺️ Flushing the current cache.")
        cache.flush()
    }
}

extension MinecraftRenderedTileOverlay: CachingTileOverlay {
    func cachedData(at path: MKTileOverlayPath) -> Data? {
        cache.getValue(forPath: path, in: self.configuration.dimension)
    }
}
