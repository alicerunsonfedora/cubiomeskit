//
//  MinecraftMapViewTests.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 05-04-2025.
//

#if canImport(MapKit)

import CachingMapKitTileOverlay
import MapKit
import SwiftUI
import Testing

@testable import CubiomesMapKit

@MainActor
struct MinecraftMapViewTests {
    @Test(.tags(.mapkit))
    func mapViewInit() throws {
        let mcWorld = try MinecraftWorld(version: "1.21", seed: 123)
        let mcMapView = MinecraftMapView(world: mcWorld, frame: .zero)

        #expect(mcMapView.mapConfiguration.ornaments == [.compass])
        #expect(mcMapView.showsScale == false)
        #if os(macOS)
        #expect(mcMapView.showsPitchControl == false)
        #endif
        #expect(mcMapView.isPitchEnabled == false)
        #expect(mcMapView.isRotateEnabled == false)
    }

    @Test(.tags(.mapkit))
    func mapViewDimensionChange() throws {
        let mcWorld = try MinecraftWorld(version: "1.21", seed: 123)
        let mcMapView = MinecraftMapView(world: mcWorld, frame: .zero)
        mcMapView.dimension = .end

        let overlay = mcMapView.minecraftOverlay as? MinecraftRenderedTileOverlay

        #expect(overlay?.configuration.dimension == .end)
    }

    @Test(.tags(.mapkit))
    func mapViewAnnotation() throws {
        let mcWorld = try MinecraftWorld(version: "1.21", seed: 123)
        let mcMapView = MinecraftMapView(world: mcWorld, frame: .zero)
        let annotationView = mcMapView.mapView(
            mcMapView,
            viewFor: MinecraftMapMarkerAnnotation(location: .zero, title: "Spawn")
        )

        #expect(annotationView != nil)
        #expect(annotationView is MKMarkerAnnotationView)
    }

    @Test(.tags(.mapkit))
    func mapViewOverlayRenderer() throws {
        let mcWorld = try MinecraftWorld(version: "1.21", seed: 123)
        let mcMapView = MinecraftMapView(world: mcWorld, frame: .zero)

        let overlay = MinecraftRenderedTileOverlay(world: mcWorld)
        let renderer = mcMapView.mapView(mcMapView, rendererFor: overlay)
        #expect(renderer is CachingTileOverlayRenderer)
    }

    @Test(.tags(.mapkit))
    func mapViewRenderCacheRefreshesOnOptionChange() throws {
        let mcWorld = try MinecraftWorld(version: "1.21", seed: 123)
        let mcMapView = MinecraftMapView(world: mcWorld, frame: .zero)
        let overlayPath = MKTileOverlayPath(x: 0, y: 0, z: 18, contentScaleFactor: 1)

        mcMapView.minecraftOverlay?.cache.set("Foo".data(using: .utf8) ?? Data(), forPath: overlayPath, in: .overworld)
        #expect(mcMapView.minecraftOverlay?.cache.getValue(forPath: overlayPath, in: .overworld) != nil)

        mcMapView.renderOptions.insert(.naturalColors)
        #expect(mcMapView.minecraftOverlay?.cache.getValue(forPath: overlayPath, in: .overworld) == nil)
    }
}


#endif