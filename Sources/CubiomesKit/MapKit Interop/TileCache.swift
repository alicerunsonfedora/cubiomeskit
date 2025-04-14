//
//  TileCache.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 14-04-2025.
//

import Foundation
import MapKit

/// A cache used to store Minecraft map tiles.
///
/// This isn't typically used directly, but as part of a renderer class, such as ``MinecraftRenderedTileOverlay``, to
/// improve the performance of map loading. Keys are built around the tile overlay paths (`MKTileOverlayPath`) and the
/// dimension the tile was generated under.
class TileCache {
    private var cache = NSCache<NSString, NSData>()

    /// Initialize a Minecraft map tile cache with a specified limit.
    /// - Parameter countLimit: The maximum number of items the cache can hold before it begins evicting unused tiles.
    init(max countLimit: Int = 200) {
        cache = NSCache()
        cache.countLimit = countLimit
        cache.name = "Minecraft Tile Cache"
    }

    /// Insert a rendered Minecraft map tile into the cache.
    /// - Parameter renderedData: The rendered tile to insert into the cache.
    /// - Parameter path: The tile overlay path that generated this tile.
    /// - Parameter dimension: The world dimension this tile corresponds to.
    func set(_ renderedData: Data, forPath path: MKTileOverlayPath, in dimension: MinecraftWorld.Dimension) {
        let key = Self.key(forPath: path, in: dimension)
        let data = NSData(data: renderedData)
        cache.setObject(data, forKey: key)
    }

    /// Retrieve a rendered Minecraft map tile from the cache.
    /// - Parameter path: The tile overlay path for the tile to retrieve.
    /// - Parameter dimension: The world dimension for the tile to retrieve.
    func getValue(forPath path: MKTileOverlayPath, in dimension: MinecraftWorld.Dimension) -> Data? {
        let key = Self.key(forPath: path, in: dimension)
        guard let result = cache.object(forKey: key) else { return nil }
        return Data(result)
    }

    /// Invalidate the cache for a given map tile.
    /// - Parameter path: The tile overlay path for the tile to invalidate.
    /// - Parameter dimension: The world dimension for the tile to invalidate.
    func invalidateValue(forPath path: MKTileOverlayPath, in dimension: MinecraftWorld.Dimension) {
        let key = Self.key(forPath: path, in: dimension)
        cache.removeObject(forKey: key)
    }

    /// Flushes the current caching context.
    func flush() {
        cache.removeAllObjects()
    }
}

extension TileCache {
    /// Generate a key from a tile overlay path and dimension.
    static func key(forPath path: MKTileOverlayPath, in dimension: MinecraftWorld.Dimension) -> NSString {
        let pathString = [path.x, path.y, path.z].map(String.init).joined(separator: ",")
        let key = "#tile(\(pathString),\(path.contentScaleFactor)), #dimension(\(dimension))"
        return NSString(string: key)
    }
}
