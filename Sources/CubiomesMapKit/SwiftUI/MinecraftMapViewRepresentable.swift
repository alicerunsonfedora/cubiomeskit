//
//  MinecraftMapViewRepresentable.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 14-02-2026.
//

import SwiftUI

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
