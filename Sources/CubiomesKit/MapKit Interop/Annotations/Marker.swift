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
public struct Marker: MinecraftMapBuilderContent, Equatable, Hashable {
    /// The location of the marker in blocks.
    public var location: CGPoint

    /// The marker's tint color as it appears on the map.
    public var color: Color

    /// The name of the marker.
    public var title: String

    /// The symbol to use for the pin.
    public var systemImage: String?

    /// The identifier used to determine whether this marker should be joined together in a cluster.
    ///
    /// Markers will generally be clustered to the default identifier. Setting a custom identifier allows markers to
    /// only be clustered to other markers of its type.
    public var clusteringIdentifier: String

    /// Create a marker at a given position.
    /// - Parameter location: The Minecraft coordinate where the marker will be placed.
    /// - Parameter title: The name of the marker.
    /// - Parameter color: The marker's tint color.
    public init(
        location: CGPoint,
        title: String,
        color: Color = .accentColor,
        systemImage: String? = nil,
        clusterIdentifier: String = "cubiomeskit-default"
    ) {
        self.location = location
        self.title = title
        self.color = color
        self.systemImage = systemImage
        self.clusteringIdentifier = clusterIdentifier
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
    public var model: Marker {
        didSet { applyModel() }
    }

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

    /// The identifier used to determine whether this marker should be joined together in a cluster.
    ///
    /// Markers will generally be clustered to the default identifier. Setting a custom identifier allows markers to
    /// only be clustered to other markers of its type.
    public private(set) var clusteringIdentifier: String

    /// Initializes an annotation from a Minecraft marker.
    public init(marker: Marker) {
        self.coordinate = CoordinateProjections.project(marker.location)
        self.title = marker.title
        self.systemImage = marker.systemImage
        self.clusteringIdentifier = marker.clusteringIdentifier
        self.model = marker

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
    public convenience init(
        location: CGPoint,
        title: String,
        color: Color = .accentColor,
        clusterIdentifier: String = "cubiomeskit-default"
    ) {
        self.init(marker: Marker(location: location, title: title, color: color, clusterIdentifier: clusterIdentifier))
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let marker = object as? Self else { return false }
        return marker.model == model
    }

    func applyModel() {
        self.coordinate = CoordinateProjections.project(model.location)
        self.title = model.title
        self.systemImage = model.systemImage
        self.clusteringIdentifier = model.clusteringIdentifier

        let xCoord = Int(model.location.x)
        let zCoord = Int(model.location.y)
        self.subtitle = "(\(xCoord), \(zCoord))"
        #if canImport(UIKit)
            self.color = UIColor(model.color)
        #else
            self.color = NSColor(model.color)
        #endif
    }
}

extension MinecraftMapMarkerAnnotation: MinecraftMapContent {
    public typealias Model = Marker
    public var contentType: MinecraftMapContentType { .annotation }
}
