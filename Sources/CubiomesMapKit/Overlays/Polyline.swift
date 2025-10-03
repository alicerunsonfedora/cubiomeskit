//
//  Polyline.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 19-08-2025.
//

import CubiomesKitCore
import MapKit
import SwiftUI

/// A polygonal line that can be displayed on a map.
///
/// Polylines consist of multiple points to draw a line between. Polylines can optionally tinted a specific color.
public struct Polyline: MinecraftMapBuilderContent, Hashable, Identifiable, Equatable {
    /// The polyline's unique identifier.
    public var id: String

    /// The points that make up the polyline.
    public var points: [CGPoint]

    /// The color of the polyline.
    public var color: Color = .blue

    /// Create a polyline.
    public init(id: String = UUID().uuidString, points: [CGPoint], color: Color = .blue) {
        self.points = points
        self.id = id
        self.color = color
    }

    public var content: any MinecraftMapContent {
        MinecraftPolyline(model: self)
    }
}

/// A polygonal line that can be displayed on a map.
///
/// Polylines consist of multiple points to draw a line between. Polylines can optionally tinted a specific color.
public class MinecraftPolyline: NSObject, MKOverlay {
    public typealias Model = Polyline

    /// The underlying model that configures the polyline overlay.
    public var model: Polyline

    public var boundingMapRect: MKMapRect { polyline.boundingMapRect }
    public var coordinate: CLLocationCoordinate2D { polyline.coordinate }

    var polyline: MKColoredPolyline

    #if canImport(UIKit)
        var color: UIColor
    #else
        var color: NSColor
    #endif

    /// Create a polyline from a model.
    public init(model: Polyline) {
        self.model = model

        #if canImport(UIKit)
            self.color = UIColor(model.color)
        #else
            self.color = NSColor(model.color)
        #endif

        let coordinates = model.points.map(CLLocationCoordinate2D.init(projecting:))
        self.polyline = MKColoredPolyline(coordinates: coordinates, count: coordinates.count)
        self.polyline.color = self.color
    }

    /// Create a polyline overlay by specifying the points and colors.
    public convenience init(id: String = UUID().uuidString, points: [CGPoint], color: Color = .blue) {
        self.init(model: Polyline(id: id, points: points, color: color))
    }

    func applyModel() {
        let coordinates = model.points.map(CLLocationCoordinate2D.init(projecting:))
        self.polyline = MKColoredPolyline(coordinates: coordinates, count: coordinates.count)
        #if canImport(UIKit)
            self.polyline.color = UIColor(model.color)
        #else
            self.polyline.color = NSColor(model.color)
        #endif
    }
}

extension MinecraftPolyline: MinecraftMapContent {
    public var contentType: MinecraftMapContentType { .overlay }
}

class MKColoredPolyline: MKPolyline {
    #if canImport(UIKit)
        var color = UIColor.systemBlue
    #else
        var color = NSColor.systemBlue
    #endif
}
