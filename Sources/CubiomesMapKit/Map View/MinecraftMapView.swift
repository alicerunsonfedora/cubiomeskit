//
//  MinecraftMapView.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 03-04-2025.
//

import CachingMapKitTileOverlay
import CubiomesKitCore
import Foundation
import MapKit
import os
import PencilKit

#if canImport(UIKit)
import UIKit
#endif

/// A map view of a Minecraft world that can be navigated and interacted with.
///
/// This map view supports typical map interactions such as panning and zooming while displaying content from a
/// Minecraft world. Tiles are dynamically loaded in with a `MinecraftWorldRenderer` as a tile overlay. The map view
/// also supports standard MapKit annotations, along with the new Minecraft map annotations.
///
/// - SeeAlso: For use in SwiftUI views, use the ``MinecraftMap`` view.
public final class MinecraftMapView: MKMapView {
    enum ConfiguredContentView {
        case annotation((any MKAnnotation) -> MKAnnotationView)
        case overlay((any MKOverlay) -> MKOverlayRenderer)
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

    /// The characteristics of the map view, specific to the Minecraft aspects of the view.
    public var mapConfiguration: MinecraftMapPreferredConfiguration {
        didSet {
            didChangeMapConfiguration()
        }
    }

    /// The dimension the map will render.
    public var dimension: MinecraftWorld.Dimension = .overworld {
        didSet {
            guard dimension != oldValue else { return }
            redrawDimensionIfNeeded()
        }
    }

    /// The rendering options to the map's renderer.
    public var renderOptions: MinecraftWorldRenderer.Options = [] {
        didSet {
            applyRenderingOptions(from: oldValue)
        }
    }

    /// The world the map view will render.
    public var world: MinecraftWorld

    /// The drawings visible on the map.
    public var drawings: [MinecraftMapDrawing]? = nil

    /// The delegate for handling interaction events.
    ///
    /// This is intended to be used as a replacement for an `MKMapViewDelegate`, as ``MinecraftMapView``s already define a
    /// delegate to display Minecraft tiles.
    public weak var mcMapViewDelegate: (any MinecraftMapViewDelegate)?

    #if canImport(UIKit)
    lazy var addDrawingButton: UIBarButtonItem = {
        UIBarButtonItem(
            title: "Add Drawing",
            image: UIImage(systemName: "plus"),
            target: self,
            action: #selector(addCurrentDrawing))
    }()

    lazy var drawingCanvas: TransientDrawingCanvas = {
        let canvas = TransientDrawingCanvas(frame: frame)
        canvas.allowsDrawing = false
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.isHidden = !mapConfiguration.allowPencilKitDrawings
        return canvas
    }()
    #endif

    var configurableContentViews: [ObjectIdentifier : ConfiguredContentView] = [:]
    var isDrawing = false {
        didSet { didChangeIsDrawing() }
    }
    var logger: Logger
    var minecraftOverlay: (any MinecraftTileOverlay)!
    var mapContent: [any MinecraftMapContent] = []

    #if canImport(UIKit)
    var toolPicker = PKToolPicker()
    #endif
    
    /// Initialize a map view for a specified Minecraft world in a given frame.
    ///
    /// - Parameter world: The Minecraft world to be rendered on the map.
    /// - Parameter frame: The frame to initialize the view in.
    /// - Parameter dimension: The dimension that the map will render the world in.
    /// - Parameter centerCoordinate: The center of the map to focus on.
    /// - Parameter preferredConfiguration: The preferred configuration to use.
    public init(
        world: MinecraftWorld,
        frame: CGRect,
        dimension: MinecraftWorld.Dimension = .overworld,
        centerCoordinate: CGPoint = .zero,
        preferredConfiguration: MinecraftMapPreferredConfiguration = .preferredDefault()
    ) {
        self.world = world
        self.dimension = dimension
        self.logger = Logger(subsystem: "net.marquiskurt.cubiomeskit", category: "\(MinecraftMapView.self)")
        self.mapConfiguration = preferredConfiguration
        super.init(frame: frame)
        self.delegate = self

        self.configureMapView()
        self.setViableAppearanceForDimension()
        self.centerCoordinate = CLLocationCoordinate2D(projecting: centerCoordinate)
    }

    /// Registers the annotation view that should appear on the map for the corresponding custom Minecraft map content.
    ///
    /// This should be used to provide views for custom Minecraft map content not already present in CubiomesKit.
    ///
    /// - Parameter annotationType: The annotation type to construct a view for.
    /// - Parameter builder: A closure that build the corresponding annotation view for the provided Minecraft map
    /// content.
    public func registerView<T: MinecraftMapContent>(
        for annotationType: T.Type,
        build builder: @escaping (
            any MKAnnotation
        ) -> MKAnnotationView
    ) {
        configurableContentViews[ObjectIdentifier(annotationType)] = .annotation(builder)
    }

    /// Registers the overlay renderer that should appear on the map for the corresponding custom Minecraft map content.
    ///
    /// This should be used to provide overlay renderers for custom Minecraft map content not already present in
    /// CubiomesKit.
    ///
    /// - Parameter overlayType: The annotation type to construct a renderer for.
    /// - Parameter builder: A closure that build the corresponding overlay renderer for the provided Minecraft map
    /// content.
    public func registerOverlay<T: MinecraftMapContent>(
        for overlayType: T.Type,
        build builder: @escaping (
            any MKOverlay
        ) -> MKOverlayRenderer
    ) {
        configurableContentViews[ObjectIdentifier(overlayType)] = .overlay(builder)
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

        self.registerAnnotationView(of: MKMarkerAnnotationView.self)
        self.registerAnnotationView(of: MinecraftMapMarkerAnnotationView.self)

        let overlay = MinecraftRenderedTileOverlay(world: world, dimension: dimension)
        self.addOverlay(overlay, level: .aboveLabels)
        self.minecraftOverlay = overlay

        #if canImport(UIKit)
        setupPencilKitSupportIfAvailable()
        #endif
    }

    func reconfigureOrnaments() {
        self.showsCompass = mapConfiguration.ornaments.contains(.compass)
        #if os(macOS)
            self.showsZoomControls = mapConfiguration.ornaments.contains(.zoom)
        #endif
        self.showsScale = mapConfiguration.ornaments.contains(.scale)
    }

    func applyRenderingOptions(from oldValue: MinecraftWorldRenderer.Options) {
        guard let minecraftOverlay = minecraftOverlay as? MinecraftRenderedTileOverlay else {
            logger.warning("The Minecraft overlay hasn't been initialized yet, or it doesn't need rendering options.")
            return
        }
        minecraftOverlay.configuration.renderingOptions = renderOptions
        if renderOptions != oldValue {
            minecraftOverlay.cache.flush()
        }
    }

    func didChangeMapConfiguration() {
        if let overlay = minecraftOverlay as? MinecraftRenderedTileOverlay {
            overlay.ephemeral = mapConfiguration.ephemeralRendering
        }
        mcMapViewDelegate?.mapView(self, didChangeEphemeralRendering: mapConfiguration.ephemeralRendering)
        reconfigureOrnaments()
        drawingCanvas.isHidden = !mapConfiguration.allowPencilKitDrawings
    }
}

extension MinecraftMapView {
    func registerAnnotationView<T: NSObject>(of type: T.Type) {
        self.register(type, forAnnotationViewWithReuseIdentifier: "\(type)")
    }
}
