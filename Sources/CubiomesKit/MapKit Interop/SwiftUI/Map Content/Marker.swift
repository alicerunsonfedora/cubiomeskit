//
//  MinecraftMapMarker.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 03-04-2025.
//

import MapKit
import SwiftUI

/// A marker on a Minecraft map.
///
/// Markers are generally used to indicate points of interest on a Minecraft world map. Tapping on a marker will
/// display its coordinate below as a subtitle.
public struct Marker: MinecraftMapBuilderContent {
    /// The location of the marker in blocks.
    public var location: CGPoint

    /// The marker's tint color as it appears on the map.
    public var color: Color

    /// The name of the marker.
    public var title: String

    /// The symbol to use for the pin.
    public var systemImage: String?

    /// Create a marker at a given position.
    /// - Parameter location: The Minecraft coordinate where the marker will be placed.
    /// - Parameter title: The name of the marker.
    /// - Parameter color: The marker's tint color.
    public init(location: CGPoint, title: String, color: Color = .accentColor, systemImage: String? = nil) {
        self.location = location
        self.title = title
        self.color = color
    }

    public var content: any MinecraftMapContent {
        MinecraftMapMarkerAnnotation(marker: self)
    }
}

/// An annotation that displays a marker on a Minecraft map.
///
/// Markers are generally used to indicate points of interest on a Minecraft world map. Tapping on a marker will
/// display its coordinate below as a subtitle.
public class MinecraftMapMarkerAnnotation: NSObject, MKAnnotation {
    /// The location of the coordinate as a Core Location coordinate.
    public private(set) var coordinate: CLLocationCoordinate2D
    #if canImport(UIKit)
        var color: UIColor
    #else
        var color: NSColor
    #endif

    /// The name of the marker.
    public var title: String?

    /// The subtitle of the marker, which displays the marker in Minecraft coordinates.
    public private(set) var subtitle: String?

    /// The symbol to use for the marker.
    public private(set) var systemImage: String?

    /// Initializes an annotation from a Minecraft marker.
    public init(marker: Marker) {
        self.coordinate = CoordinateProjections.project(marker.location)
        self.title = marker.title
        self.systemImage = marker.systemImage

        let xCoord = Int(marker.location.x)
        let zCoord = Int(marker.location.y)
        self.subtitle = "(\(xCoord), \(zCoord))"
        #if canImport(UIKit)
            self.color = UIColor(marker.color)
        #else
            self.color = NSColor(marker.color)
        #endif
    }

    /// Initializes a marker annotation.
    /// - Parameter location: The location of the marker in Minecraft block coordinates.
    /// - Parameter title: The name of the marker.
    /// - Parameter color: The tint color of the marker pin.
    public init(location: CGPoint, title: String, color: Color = .accentColor) {
        self.coordinate = CoordinateProjections.project(location)
        self.title = title
        self.systemImage = nil

        let xCoord = Int(location.x)
        let zCoord = Int(location.y)
        self.subtitle = "(\(xCoord), \(zCoord))"
        #if canImport(UIKit)
            self.color = UIColor(color)
        #else
            self.color = NSColor(color)
        #endif
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let marker = object as? Self else { return false }
        return marker.coordinate == self.coordinate && marker.title == self.title && marker.subtitle == self.subtitle
            && marker.color == self.color && marker.systemImage == self.systemImage
    }
}

extension MinecraftMapMarkerAnnotation: MinecraftMapContent {
    public var contentType: MinecraftMapContentType { .annotation }
}
