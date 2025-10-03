//
//  PolylineTests.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 19-08-2025.
//

#if canImport(MapKit)

import CubiomesKitCore
import MapKit
import SwiftUI
import Testing

@testable import CubiomesMapKit

struct PolylineTests {
    @Test func overlayInitFromModel() throws {
        let polyline = MinecraftPolyline(points: [.zero, CGPoint(x: 64, y: 64)])

        #expect(!polyline.model.id.isEmpty)
        #expect(polyline.model.points == [.zero, CGPoint(x: 64, y: 64)])
        #expect(polyline.model.color == .blue)
    }

    @Test func overlyContent() throws {
        let polyline = Polyline(points: [.zero, CGPoint(x: 64, y: 64)])

        #expect(polyline.content is MinecraftPolyline)
    }
}

#endif
