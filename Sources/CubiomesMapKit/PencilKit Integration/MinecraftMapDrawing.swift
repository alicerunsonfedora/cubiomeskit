//
//  MinecraftMapDrawing.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 08-12-2025.
//

import MapKit
import PencilKit

public struct MinecraftMapDrawing: Sendable, Codable {
    /// The drawing being displayed on the map.
    public var drawing: PKDrawing

    /// The location where the drawing is displayed.
    public var location: CLLocationCoordinate2D

    /// The drawing's map bounds.
    public var mapRect: MKMapRect
}
