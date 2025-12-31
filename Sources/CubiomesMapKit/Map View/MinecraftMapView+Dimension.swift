//
//  MinecraftMapView+Dimension.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 08-12-2025.
//

import CachingMapKitTileOverlay
import CubiomesKitCore
import MapKit

extension MinecraftMapView {
    func redrawDimensionIfNeeded() {
        guard let minecraftOverlay else { return }
        if let renderedOverlay = minecraftOverlay as? MinecraftRenderedTileOverlay {
            renderedOverlay.configuration.dimension = self.dimension

            // NOTE(alicerunsonfedora): For some reason, a second cache flush is needed to get the map to fully clear
            //out the tiles. Might be a beta SDK bug, or it could be some unintentional race condition caused by
            // NSCache.
            renderedOverlay.cache.flush()
        }
        if let renderer = renderer(for: minecraftOverlay) as? CachingTileOverlayRenderer {
            renderer.setNeedsDisplay()
        }
        self.setViableAppearanceForDimension()
    }

    func setViableAppearanceForDimension() {
        guard mapConfiguration.dimensionDeterminesSystemAppearance else {
            #if os(macOS)
            self.appearance = .currentDrawing()
            #else
            self.overrideUserInterfaceStyle = .unspecified
            #endif
            return
        }

        switch dimension {
        case .overworld, .end:
            #if os(macOS)
            self.appearance = NSAppearance(named: .aqua)
            #else
            self.overrideUserInterfaceStyle = .light
            #endif
        default:
            #if os(macOS)
            self.appearance = .currentDrawing()
            #else
            self.overrideUserInterfaceStyle = .dark
            #endif
        }
    }
}
