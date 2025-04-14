//
//  MinecraftRenderedTileOverlay.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 03-04-2025.
//

import os
import MapKit

final class MinecraftRenderedTileOverlay: MKTileOverlay {
    var ephemeral: Bool = false
    var world: MinecraftWorld
    var dimension: MinecraftWorld.Dimension = .overworld
    let renderer: MinecraftWorldRenderer

    let cache: TileCache
    let logger: Logger

    init(world: MinecraftWorld, dimension: MinecraftWorld.Dimension = .overworld) {
        self.world = world
        self.dimension = dimension
        self.renderer = MinecraftWorldRenderer(world: world)
        self.renderer.options = []
        self.cache = TileCache()
        self.logger = Logger()

        super.init(urlTemplate: nil)
        self.canReplaceMapContent = true
    }

    enum Constants {
        // NOTE(alicerunsonfedora): This needs to be a power of 2!

        static let minBoundary = -33_554_432  // -29_999_984 is world border
        static let maxBoundary = 33_554_432  // 29_999_984 is world border
    }

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, (any Error)?) -> Void) {
        let chunk = chunk(forOverlayPath: path)

        if !ephemeral, let data = cache.getValue(forPath: path, in: dimension) {
            logger.debug("Tile cache hit for path (\(TileCache.key(forPath: path, in: self.dimension)))")
            result(data, nil)
            return
        }

        if ephemeral {
            logger.warning("Tile renderer is ephemeral, which will always generate new tiles.")
        } else {
            logger.debug("Tile cache miss for path (\(TileCache.key(forPath: path, in: self.dimension)))")
        }
        let data = renderer.render(inRegion: chunk, scale: 1, dimension: dimension)
        if !ephemeral { cache.set(data, forPath: path, in: dimension) }
        result(data, nil)
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
            origin: MinecraftPoint(x: posX, y: 15, z: posZ),
            scale: MinecraftWorldRect.Size(squaring: Int32(blockPerTile)))

        logger.debug("Mapping at current scale: 🔳 \(totalTilesOnAxis), 🧱 \(blockPerTile)")
        logger.debug(
            "🗺️ [\(path.x), \(path.y) @ \(path.z)] -> 🍱 [\(chunk.origin.x), \(chunk.origin.z) @ \(blockPerTile)]")
        return chunk
    }
}
