//
//  MinecraftMapView.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 03-04-2025.
//

import Foundation
import MapKit

/// A map view of a Minecraft world that can be navigated and interacted with.
///
/// This map view supports typical map interactions such as panning and zooming while displaying content from a
/// Minecraft world. Tiles are dynamically loaded in with a ``MinecraftWorldRenderer`` as a tile overlay. The map view
/// also supports standard MapKit annotations, along with the new Minecraft map annotations.
///
/// - SeeAlso: For use in SwiftUI views, use the ``MinecraftMap`` view.
public final class MinecraftMapView: MKMapView {
    /// A set of views and controls that sit above the map.
    public struct Ornaments: OptionSet, Sendable {
        /// The raw value of the option set.
        public let rawValue: Int

        /// Display the map compass.
        public static let compass = Ornaments(rawValue: 1 << 0)

        /// Display controls for zooming in and out of the map.
        public static let zoom = Ornaments(rawValue: 1 << 1)

        /// Display a map scale ornament.
        ///
        /// This ornament is generally used to display a scale control that represents the scale of a map in meters.
        ///
        /// - Note: This view might be inaccurate regarding scaling.
        public static let scale = Ornaments(rawValue: 1 << 2)

        /// Display all available ornaments.
        public static let all: Ornaments = [.compass, .zoom, .scale]

        /// Initializes an ornament option.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    /// The center coordinate of the map view, represented as a Minecraft block coordinate.
    ///
    /// This closely resembles the `centerCoordinate` property. Setting this value will automatically update this value
    /// by projecting it into a Core Location coordinate.
    public var centerBlockCoordinate: CGPoint {
        get { return CoordinateProjections.unproject(centerCoordinate) }
        set {
            DispatchQueue.main.async { [weak self] in
                self?.setCenter(CoordinateProjections.project(newValue), animated: true)
            }
        }
    }

    /// The dimension the map will render.
    public var dimension: MinecraftWorld.Dimension = .overworld {
        didSet {
            redrawDimension()
        }
    }

    /// Whether Minecraft map tiles should be rendered ephemerally (i.e., without caching).
    ///
    /// By default, the tile overlay renderer will create and use a cache to store generated tiles to improve
    /// performance, rather than regenerating the tile every time it is requested. However, this behavior can be
    /// disabled for debugging purposes or for other reasons.
    ///
    /// - Note: This option will always return false in the ``MinecraftMap`` view. If you need the SwiftUI view to
    ///   leverage ephemeral rendering, create a wrapper around ``MinecraftMapView``.
    /// - Important: To improve performance in your apps, it is recommended to keep this option disabled.
    public var ephemeralRendering: Bool = false {
        didSet {
            minecraftOverlay?.ephemeral = ephemeralRendering
            mcMapViewDelegate?.mapView(self, didChangeEphemeralRendering: ephemeralRendering)
        }
    }
    
    /// The rendering options to the map's renderer.
    public var renderOptions: MinecraftWorldRenderer.Options = [] {
        didSet {
            minecraftOverlay?.renderer.options = renderOptions
        }
    }

    /// The ornaments that should be displayed on top of the map view.
    public var ornaments: Ornaments = [.compass] {
        didSet { reconfigureOrnaments() }
    }

    /// The world the map view will render.
    public var world: MinecraftWorld

    /// The delegate for handling interaction events.
    ///
    /// This is intended to be used as a replacement for an `MKMapViewDelegate`, as ``MinecraftMapView``s already define a
    /// delegate to display Minecraft tiles.
    public weak var mcMapViewDelegate: (any MinecraftMapViewDelegate)?

    var minecraftOverlay: MinecraftRenderedTileOverlay!
    var mapContent: [any MinecraftMapContent] = []

    /// Initialize a map view for a specified Minecraft world in a given frame.
    ///
    /// - Parameter world: The Minecraft world to be rendered on the map.
    /// - Parameter frame: The frame to initialize the view in.
    /// - Parameter dimension: The dimension that the map will render the world in.
    public init(world: MinecraftWorld, frame: CGRect, dimension: MinecraftWorld.Dimension = .overworld) {
        self.world = world
        self.dimension = dimension
        super.init(frame: frame)
        self.delegate = self

        self.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: "\(MKMarkerAnnotationView.self)")

        self.configureMapView()
        self.centerCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)

        let overlay = MinecraftRenderedTileOverlay(world: world, dimension: dimension)
        self.addOverlay(overlay, level: .aboveLabels)
        self.minecraftOverlay = overlay
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureMapView() {
        #if os(macOS)
            self.canDrawConcurrently = true
        #endif
        self.cameraZoomRange = CameraZoomRange(minCenterCoordinateDistance: 64, maxCenterCoordinateDistance: 256)
        self.isPitchEnabled = false
        self.isZoomEnabled = true
        self.isRotateEnabled = false
    }

    func reconfigureOrnaments() {
        self.showsCompass = ornaments.contains(.compass)
        #if os(macOS)
            self.showsZoomControls = ornaments.contains(.zoom)
        #endif
        self.showsScale = ornaments.contains(.scale)
    }

    func redrawDimension() {
        guard let minecraftOverlay else { return }
        minecraftOverlay.dimension = self.dimension
        if let renderer = renderer(for: minecraftOverlay) as? MKTileOverlayRenderer {
            renderer.reloadData()
        }
    }

    static func compareAnnotations(_ lhs: any MKAnnotation, _ rhs: any MKAnnotation) -> Bool {
        switch (lhs, rhs) {
        case let (lhs as MinecraftMapMarkerAnnotation, rhs as MinecraftMapMarkerAnnotation):
            return lhs.coordinate == rhs.coordinate && lhs.title == rhs.title
        default:
            return lhs.coordinate == rhs.coordinate
        }
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
