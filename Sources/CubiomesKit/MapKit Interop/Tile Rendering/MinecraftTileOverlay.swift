//
//  MinecraftTileOverlay.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 11-07-2025.
//

import CachingMapKitTileOverlay
import MapKit

protocol MinecraftTileOverlay: MKTileOverlay, CachingTileOverlay {
    associatedtype Configuration

    var configuration: Configuration { get set }
    var cache: TileCache { get }

    init(withConfiguration configuration: Configuration)
}
