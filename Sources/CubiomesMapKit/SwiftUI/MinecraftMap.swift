//
//  MinecraftMap.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 03-04-2025.
//

import CubiomesKitCore
import MapKit
import SwiftUI

/// A map view of a Minecraft world that can be navigated and interacted with.
///
/// This map view supports typical map interactions such as panning and zooming while displaying content from a
/// Minecraft world. Tiles are dynamically loaded in with a `MinecraftWorldRenderer`.
///
/// - SeeAlso: For use in AppKit/UIKit views, use the ``MinecraftMapView``.
public struct MinecraftMap {
    /// A type alias representing the map's ornaments displayed in the view above the map's content.
    public typealias Ornaments = MinecraftMapPreferredConfiguration.Ornaments

    /// An enumeration representing the various color schemes available to the map.
    public enum ColorScheme {
        /// The default color scheme.
        ///
        /// This color scheme is automatically provided by Cubiomes and uses the same color scheme for biomes as other
        /// tools, such as Chunkbase, Amidst, and MineAtlas.
        case `default`

        /// The natural color scheme.
        ///
        /// This color scheme is bundled in CubiomesKit. It aims to represent real Minecraft blocks, providing a more
        /// natural and consistent look with the Minecraft world.
        case natural
    }

    /// The coordinator for this map.
    ///
    /// The coordinator is used to handle delegate events fired from the view's map delegate,
    /// ``MinecraftMapViewDelegate``. It cannot be initialized outside of the ``MinecraftMap`` context. To directly
    /// access delegate events, use the appropriate view modifiers.
    public class Coordinator: @preconcurrency MinecraftMapViewDelegate {
        var parent: MinecraftMap

        init(parent: MinecraftMap) {
            self.parent = parent
        }

        @MainActor
        public func mapView(_ mapView: MinecraftMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async { [self] in
                parent.centerCoordinate = mapView.centerBlockCoordinate
            }
        }

        public func mapView(_ mapView: MinecraftMapView, addedDrawing drawing: MinecraftMapDrawing) {
            self.parent.addedDrawingCallback?(drawing)
        }
    }

    @Binding var centerCoordinate: CGPoint
    @Binding var isDrawing: Bool
    
    var world: MinecraftWorld

    var addedDrawingCallback: ((MinecraftMapDrawing) -> Void)?
    var dimension: MinecraftWorld.Dimension = .overworld
    var ornaments: Ornaments = []
    var annotations: [any MinecraftMapContent] = []
    var pencilKitSupported = false
    var preferNaturalColors: Bool = false
    var automaticMapSystemAppearance: Bool = true
    var configuredContentViews: [ObjectIdentifier: MinecraftMapView.ConfiguredContentView] = [:]

    /// Create a Minecraft map view.
    /// - Parameter world: The world to display in the map view.
    /// - Parameter centerCoordinate: The coordinate that should be in the center of the map view.
    /// - Parameter dimension: The dimension to view the world in.
    public init(
        world: MinecraftWorld,
        centerCoordinate: Binding<CGPoint>? = nil,
        dimension: MinecraftWorld.Dimension = .overworld
    ) {
        self.world = world
        self.dimension = dimension
        self._centerCoordinate = centerCoordinate ?? Binding.constant(.zero)
        self._isDrawing = Binding.constant(false)
    }

    /// Create a Minecraft map view with additional annotations.
    /// - Parameter world: The world to display in the map view.
    /// - Parameter centerCoordinate: The coordinate that should be in the center of the map view.
    /// - Parameter dimension: The dimension to view the world in.
    /// - Parameter annotations: The annotations that should be displayed in the world.
    public init(
        world: MinecraftWorld,
        centerCoordinate: Binding<CGPoint>? = nil,
        dimension: MinecraftWorld.Dimension = .overworld,
        @MinecraftMapContentBuilder annotations: () -> [any MinecraftMapContent]
    ) {
        self.world = world
        self.dimension = dimension
        self._centerCoordinate = centerCoordinate ?? Binding.constant(.zero)
        self._isDrawing = Binding.constant(false)
        self.annotations = annotations()
    }

    @MainActor
    func createMapView() -> MinecraftMapView {
        let mapView = MinecraftMapView(world: world, frame: .zero, centerCoordinate: centerCoordinate)
        mapView.mapConfiguration.ornaments = ornaments
        mapView.mapConfiguration.allowPencilKitDrawings = pencilKitSupported
        mapView.dimension = dimension
        mapView.addMapContents(annotations)
        mapView.mapContent = annotations
        if preferNaturalColors {
            mapView.renderOptions.insert(.naturalColors)
        } else {
            mapView.renderOptions.remove(.naturalColors)
        }
        mapView.configurableContentViews = configuredContentViews
        return mapView
    }

    @MainActor
    func updateMapView(_ mapView: MinecraftMapView) {
        mapView.mapConfiguration.ornaments = ornaments
        mapView.mapConfiguration.allowPencilKitDrawings = pencilKitSupported
        #if canImport(UIKit)
            mapView.isDrawing = isDrawing
        #endif
        mapView.dimension = dimension
        mapView.configurableContentViews = configuredContentViews
        if mapView.centerBlockCoordinate != centerCoordinate {
            mapView.centerBlockCoordinate = centerCoordinate
        }
        mapView.resyncMapContentIfNeeded(annotations)

        if preferNaturalColors {
            mapView.renderOptions.insert(.naturalColors)
        } else {
            mapView.renderOptions.remove(.naturalColors)
        }
    }

    /// Determines the map control ornaments that should be displayed on the map.
    public func ornaments(_ ornaments: Ornaments) -> MinecraftMap {
        var newSelf = self
        newSelf.ornaments = ornaments
        return newSelf
    }

    /// Specify the color scheme to be used in the map view.
    /// - Parameter colorScheme: The color scheme to use in the map view.
    public func mapColorScheme(_ colorScheme: MinecraftMap.ColorScheme) -> MinecraftMap {
        var newSelf = self
        newSelf.preferNaturalColors = colorScheme == .natural
        return newSelf
    }

    /// Determines whether the map view's preferred color scheme is inferred from the world dimension instead of the
    /// parent view.
    ///
    /// By default, the map will automatically determine the appropriate system appearance to use based on the current
    /// dimension provided to ensure legibility. Setting this modifier to false disables the behavior, falling back to
    /// the parent view's ``MinecraftMap/preferredColorScheme(_:)``.
    public func dimensionDeterminesPreferredColorScheme(_ allowed: Bool = true) -> MinecraftMap {
        var newSelf = self
        newSelf.automaticMapSystemAppearance = allowed
        return newSelf
    }

    /// Specifies the annotation view that should appear on the map for the corresponding custom Minecraft map content.
    ///
    /// This should be used to provide view for custom Minecraft map content not already present in CubiomesKit.
    /// Default CubiomesKit content such as the ``Marker`` already have views defined and do not need to be redeclared.
    ///
    /// - Parameter annotationType: The annotation type to construct a view for.
    /// - Parameter builder: A closure that build the corresponding annotation view for the provided Minecraft map
    /// content.
    public func annotationView<T: MinecraftMapContent>(
        for annotationType: T.Type,
        build builder: @escaping (any MKAnnotation) -> MKAnnotationView
    ) -> MinecraftMap {
        var newSelf = self
        var newViews = configuredContentViews
        newViews[ObjectIdentifier(annotationType)] = .annotation(builder)
        newSelf.configuredContentViews = newViews
        return newSelf
    }

    /// Specifies the overlay renderer that should appear on the map for the corresponding custom Minecraft map content.
    ///
    /// This should be used to provide an overlay renderer for custom Minecraft map content not already present in
    /// CubiomesKit. Default CubiomesKit content such as the ``Polyline`` already have renderers defined and do not
    /// need to be redeclared.
    ///
    /// - Parameter overlayType: The overlay type to construct a renderer for.
    /// - Parameter builder: A closure that build the corresponding overlay renderer for the provided Minecraft map
    /// content.
    public func overlayRenderer<T: MinecraftMapContent>(
        for overlayType: T.Type,
        build builder: @escaping (any MKOverlay) -> MKOverlayRenderer
    ) -> MinecraftMap {
        var newSelf = self
        var newViews = configuredContentViews
        newViews[ObjectIdentifier(overlayType)] = .overlay(builder)
        newSelf.configuredContentViews = newViews
        return newSelf
    }

    #if canImport(UIKit)
    /// Allows the map to support drawing via PencilKit.
    public func allowsPencilKitDrawings(_ active: Bool = true) -> Self {
        var newSelf = self
        newSelf.pencilKitSupported = active
        return newSelf
    }

    /// Listens for whenever a drawing has been added to the map.
    /// - Parameter callback: The callback to execute when a drawing has been added.
    public func addedMapDrawing(_ callback: @escaping (MinecraftMapDrawing) -> Void) -> Self {
        var newSelf = self
        newSelf.addedDrawingCallback = callback
        return newSelf
    }

    /// Tells the map view to activate the drawing canvas.
    /// - Parameter isDrawing: Whether the canvas should be active.
    public func activateDrawingCanvas(isDrawing: Binding<Bool>) -> Self {
        var newSelf = self
        newSelf._isDrawing = isDrawing
        return newSelf
    }
    #endif
}

// MARK: - View Representable Conformance

#if canImport(AppKit)
    extension MinecraftMap: NSViewRepresentable {
        public typealias UIViewType = MinecraftMapView

        public func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }

        public func makeNSView(context: Context) -> MinecraftMapView {
            let mapView = createMapView()
            mapView.mcMapViewDelegate = context.coordinator
            return mapView
        }

        public func updateNSView(_ nsView: MinecraftMapView, context: Context) {
            context.coordinator.parent = self
            updateMapView(nsView)
        }
    }
#endif

#if canImport(UIKit)
    extension MinecraftMap: UIViewRepresentable {
        public typealias UIViewType = MinecraftMapView

        public func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }

        public func makeUIView(context: Context) -> MinecraftMapView {
            let mapView = createMapView()
            mapView.mcMapViewDelegate = context.coordinator
            return mapView
        }

        public func updateUIView(_ uiView: MinecraftMapView, context: Context) {
            context.coordinator.parent = self
            updateMapView(uiView)
        }
    }
#endif
