//
//  TileCacheTests.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 14-04-2025.
//

import Foundation
import MapKit
import Testing

@testable import CubiomesKit

struct TileCacheTests {
    @Test func cacheKeying() throws {
        let tilePath = MKTileOverlayPath(x: 0, y: 0, z: 2, contentScaleFactor: 1)
        let key = TileCache.key(forPath: tilePath, in: .overworld)
        #expect(key == NSString(string: "#tile(0,0,2,1.0), #dimension(overworld)"))
    }

    @Test func cacheInsertion() throws {
        let cache = TileCache(max: 5)
        let tilePath = MKTileOverlayPath(x: 0, y: 0, z: 2, contentScaleFactor: 1)
        let data = "Foo".data(using: .utf8)!
        cache.set(data, forPath: tilePath, in: .overworld)

        let retrieved = cache.getValue(forPath: tilePath, in: .overworld)
        #expect(retrieved == data)
    }

    @Test func cacheInvalidate() throws {
        let cache = TileCache(max: 5)
        let tilePath = MKTileOverlayPath(x: 0, y: 0, z: 2, contentScaleFactor: 1)
        let data = "Foo".data(using: .utf8)!
        cache.set(data, forPath: tilePath, in: .overworld)

        let retrieved = cache.getValue(forPath: tilePath, in: .overworld)
        #expect(retrieved == data)

        cache.invalidateValue(forPath: tilePath, in: .overworld)
        let retrievedAgain = cache.getValue(forPath: tilePath, in: .overworld)
        #expect(retrievedAgain == nil)
    }

    @Test func cacheFlush() throws {
        let cache = TileCache(max: 5)
        for i in 0...2 {
            let tilePath = MKTileOverlayPath(x: i, y: i, z: 2, contentScaleFactor: 1.0)
            let data = "Foo \(i)".data(using: .utf8)!
            cache.set(data, forPath: tilePath, in: .overworld)

            let retrieved = cache.getValue(forPath: tilePath, in: .overworld)
            #expect(retrieved != nil)
        }

        cache.flush()

        for i in 0...2 {
            let tilePath = MKTileOverlayPath(x: i, y: i, z: 2, contentScaleFactor: 1.0)
            let retrieved = cache.getValue(forPath: tilePath, in: .overworld)
            #expect(retrieved == nil)
        }
    }
}
