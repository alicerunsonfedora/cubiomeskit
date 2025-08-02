//
//  MinecraftMapViewContentTests.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 31-07-2025.
//

import Foundation
import Testing

@testable import CubiomesKit

@MainActor
struct MinecraftMapViewContentTests {
    let world = MinecraftWorld(version: MC_1_21, seed: 123)

    @Test(.tags(.mapkit))
    func mapViewInsertsGeneralContent() throws {
        let view = MinecraftMapView(world: world, frame: .zero)
        #expect(view.annotations.isEmpty)

        let contents: [AnyMinecraftMapContent] = buildMinecraftMapContent {
            Marker(location: .zero, title: "Origin", id: "sample")
        }
        view.resyncMapContentIfNeeded(contents)
        #expect(view.annotations.count == 1)
    }

    @Test(.tags(.mapkit))
    func mapViewInsertsPlayerContent() throws {
        let view = MinecraftMapView(world: world, frame: .zero)
        #expect(view.annotations.isEmpty)

        let id = UUID()
        let contents: [AnyMinecraftMapContent] = buildMinecraftMapContent {
            PlayerMarker(location: .zero, name: "lweiss", playerUUID: id)
        }
        view.resyncMapContentIfNeeded(contents)

        guard let playerMarker = view.annotations.first as? MinecraftMapPlayerMarkerAnnotation else {
            Issue.record("The annotation isn't a player marker, or no markers exist.")
            return
        }

        #expect(
            playerMarker
                == MinecraftMapPlayerMarkerAnnotation(
                    name: "lweiss",
                    playerUUID: id,
                    location: .zero
                )
        )
    }

    @Test(.tags(.mapkit))
    func mapViewUpdatesPlayerContentInPlace() throws {
        let view = MinecraftMapView(world: world, frame: .zero)
        #expect(view.annotations.isEmpty)

        let id = UUID()
        let contents: [AnyMinecraftMapContent] = buildMinecraftMapContent {
            PlayerMarker(location: .zero, name: "lweiss", playerUUID: id)
        }
        view.resyncMapContentIfNeeded(contents)

        guard let playerMarker = view.annotations.first as? MinecraftMapPlayerMarkerAnnotation else {
            Issue.record("The annotation isn't a player marker, or no markers exist.")
            return
        }

        #expect(
            playerMarker
                == MinecraftMapPlayerMarkerAnnotation(
                    name: "lweiss",
                    playerUUID: id,
                    location: .zero
                )
        )

        let newContents: [AnyMinecraftMapContent] = buildMinecraftMapContent {
            PlayerMarker(location: CGPoint(x: 1847, y: 1963), name: "lweiss", playerUUID: id)
        }
        view.resyncMapContentIfNeeded(newContents)

        guard let playerMarker = view.annotations.first as? MinecraftMapPlayerMarkerAnnotation else {
            Issue.record("The annotation isn't a player marker, or no markers exist.")
            return
        }

        #expect(
            playerMarker.model == PlayerMarker(location: CGPoint(x: 1847, y: 1963), name: "lweiss", playerUUID: id)
        )
    }

    @Test(.tags(.mapkit))
    func mapViewUpdatesMarkerContentInPlace() throws {
        let view = MinecraftMapView(world: world, frame: .zero)
        #expect(view.annotations.isEmpty)

        let id = UUID()
        let contents: [AnyMinecraftMapContent] = buildMinecraftMapContent {
            Marker(location: .zero, title: "Spawn", id: id)
        }
        view.resyncMapContentIfNeeded(contents)

        guard let marker = view.annotations.first as? MinecraftMapMarkerAnnotation else {
            Issue.record("The annotation isn't a marker, or no markers exist.")
            return
        }

        #expect(
            marker.model == Marker(location: .zero, title: "Spawn", id: id)
        )

        let newContents: [AnyMinecraftMapContent] = buildMinecraftMapContent {
            Marker(location: CGPoint(x: 1847, y: 1847), title: "Spawn", id: id)
        }
        view.resyncMapContentIfNeeded(newContents)

        guard let playerMarker = view.annotations.first as? MinecraftMapMarkerAnnotation else {
            Issue.record("The annotation isn't a marker, or no markers exist.")
            return
        }

        #expect(
            playerMarker.model == Marker(location: CGPoint(x: 1847, y: 1847), title: "Spawn", id: id)
        )
    }
}
