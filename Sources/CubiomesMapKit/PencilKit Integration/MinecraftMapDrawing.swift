//
//  MinecraftMapDrawing.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 08-12-2025.
//

import MapKit
import PencilKit

public struct MinecraftMapDrawing: Sendable, Codable, Hashable, Identifiable {
    public var id: UUID = UUID()

    /// The drawing being displayed on the map.
    public var drawing: PKDrawing

    /// The location where the drawing is displayed.
    public var location: CLLocationCoordinate2D

    /// The drawing's map bounds.
    public var mapRect: MKMapRect

    public init(drawing: PKDrawing, location: CLLocationCoordinate2D, mapRect: MKMapRect) {
        self.drawing = drawing
        self.location = location
        self.mapRect = mapRect
    }
}

extension PKDrawing: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        if #available(iOS 18, macOS 15, *) {
            hasher.combine(self.bounds)
        }
        if #available(iOS 17, macOS 14, *) {
            hasher.combine(self.requiredContentVersion)
        }
        hasher.combine(self.dataRepresentation())
    }
}

extension CLLocationCoordinate2D: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(longitude)
        hasher.combine(latitude)
    }
}

extension MKMapRect: @retroactive Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin.x)
        hasher.combine(origin.y)
        hasher.combine(width)
        hasher.combine(height)
    }

    public static func == (lhs: MKMapRect, rhs: MKMapRect) -> Bool {
        lhs.origin.x == rhs.origin.x
            && lhs.origin.y == rhs.origin.y
            && lhs.width == rhs.width
            && lhs.height == rhs.height
    }
}
