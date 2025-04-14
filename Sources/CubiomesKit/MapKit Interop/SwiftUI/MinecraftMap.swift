//
//  MinecraftMap.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 03-04-2025.
//

import MapKit
import SwiftUI

/// A map view of a Minecraft world that can be navigated and interacted with.
///
/// This map view supports typical map interactions such as panning and zooming while displaying content from a
/// Minecraft world. Tiles are dynamically loaded in with a ``MinecraftWorldRenderer``.
///
/// - SeeAlso: For use in AppKit/UIKit views, use the ``MinecraftMapView``.
public struct MinecraftMap {
    /// A type alias representing the map's ornaments displayed in the view above the map's content.
    public typealias Ornaments = MinecraftMapView.Ornaments

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
        public func mapViewDidChangeVisibleRegion(_ mapView: MinecraftMapView) {
            DispatchQueue.main.async { [self] in
                parent.centerCoordinate = mapView.centerBlockCoordinate
            }
        }
    }

    @Binding var centerCoordinate: CGPoint
    var world: MinecraftWorld

    var dimension: MinecraftWorld.Dimension = .overworld
    var ornaments: Ornaments = []
    var annotations: [any MinecraftMapContent] = []
    var preferNaturalColors: Bool = false

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
        self.annotations = annotations()
    }

    init(
        world: MinecraftWorld,
        centerCoordinate: Binding<CGPoint>? = nil,
        ornaments: Ornaments = [],
        annotations: [any MinecraftMapContent] = [],
        dimension: MinecraftWorld.Dimension = .overworld,
        preferNaturalColors: Bool = false
    ) {
        self.world = world
        self.ornaments = ornaments
        self._centerCoordinate = centerCoordinate ?? Binding.constant(.zero)
        self.dimension = dimension
        self.annotations = annotations
        self.preferNaturalColors = preferNaturalColors
    }

    @MainActor
    func createMapView() -> MinecraftMapView {
        let mapView = MinecraftMapView(world: world, frame: .zero)
        #if DEBUG
            mapView.ephemeralRendering = true
        #endif
        mapView.ornaments = ornaments
        mapView.dimension = dimension
        mapView.centerBlockCoordinate = centerCoordinate
        mapView.addMapContents(annotations)
        if preferNaturalColors {
            mapView.renderOptions.insert(.naturalColors)
        } else {
            mapView.renderOptions.remove(.naturalColors)
        }
        return mapView
    }

    @MainActor
    func updateMapView(_ mapView: MinecraftMapView) {
        mapView.ornaments = ornaments
        mapView.dimension = dimension
        if mapView.centerBlockCoordinate != centerCoordinate {
            mapView.centerBlockCoordinate = centerCoordinate
        }
        mapView.resyncMapContent(annotations)

        if preferNaturalColors {
            mapView.renderOptions.insert(.naturalColors)
        } else {
            mapView.renderOptions.remove(.naturalColors)
        }
    }

    /// Determines the map control ornaments that should be displayed on the map.
    public func ornaments(_ ornaments: Ornaments) -> MinecraftMap {
        MinecraftMap(
            world: self.world,
            centerCoordinate: self._centerCoordinate,
            ornaments: ornaments,
            annotations: self.annotations,
            dimension: self.dimension,
            preferNaturalColors: self.preferNaturalColors
        )
    }

    /// Specify the color scheme to be used in the map view.
    /// - Parameter colorScheme: The color scheme to use in the map view.
    public func mapColorScheme(_ colorScheme: MinecraftMap.ColorScheme) -> MinecraftMap {
        MinecraftMap(
            world: self.world,
            centerCoordinate: self._centerCoordinate,
            ornaments: self.ornaments,
            annotations: self.annotations,
            dimension: self.dimension,
            preferNaturalColors: colorScheme == .natural
        )
    }
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
            nsView.mcMapViewDelegate = context.coordinator
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
            uiView.mcMapViewDelegate = context.coordinator
            updateMapView(uiView)
        }
    }
#endif
