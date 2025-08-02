//
//  ManagedAnnotationTests.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 02-08-2025.
//

import Foundation
import MapKit
import Testing

@testable import CubiomesKit

struct ManagedAnnotationTests {
    @Test func zipsCorrectly() async throws {
        let playerID = UUID()
        let myContent = buildMinecraftMapContent {
            Marker(location: .zero, title: "Spawn", id: "spawn")
            Marker(location: CGPoint(x: 10, y: 10), title: "Totally Not Spawn", id: "notspawn")
            PlayerMarker(location: .zero, name: "foobar", playerUUID: playerID)
        }
        let annotations: [any MKAnnotation] = [
            MinecraftMapMarkerAnnotation(marker: Marker(location: .zero, title: "Spawn", id: "spawn")),
            MinecraftMapPlayerMarkerAnnotation(name: "foobear", playerUUID: UUID(), location: .zero)
        ]

        let managedCollection = ManagedAnnotationCollection(annotations: annotations, contents: myContent)
        #expect(!managedCollection.isEmpty)
        #expect(
            managedCollection
                .countActions()
                == ManagedAnnotationCollection
                .Count(additions: 2, inPlaceUpdates: 0, deletions: 1, ignored: 1)
        )
    }    
}
