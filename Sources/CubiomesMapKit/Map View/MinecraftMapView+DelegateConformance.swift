//
//  MinecraftMapView+DelegateConformance.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 14-04-2025.
//

import CachingMapKitTileOverlay
import CubiomesKitCore
import Foundation
import MapKit
import SwiftUI

extension MinecraftMapView: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mcMapViewDelegate?.mapView(self, regionDidChangeAnimated: animated)
    }

    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mcMapViewDelegate?.mapView(self, didSelect: view)
    }

    public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        mcMapViewDelegate?.mapViewDidChangeVisibleRegion(self)
    }

    public func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case let overlay as any MinecraftTileOverlay:
            return CachingTileOverlayRenderer(overlay: overlay)
        case let polyline as MKColoredPolyline:
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = polyline.color
            renderer.lineWidth = 4
            return renderer
        default:
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    public func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView?
        if let marker = annotation as? MinecraftMapMarkerAnnotation {
            annotationView = markerAnnotationView(for: marker, in: mapView)
        } else if let player = annotation as? MinecraftMapPlayerMarkerAnnotation {
            annotationView = playerMarkerAnnotationView(for: player, in: mapView)
        } else if let configurable = annotation as? any MinecraftMapContent {
            let typeOfConfigurableView = type(of: configurable)
            if let builder = configurableContentViews[ObjectIdentifier(typeOfConfigurableView.self)] {
                switch builder {
                case let .annotation(builder):
                    annotationView = builder(annotation)
                case .overlay:
                    break
                }
            }
        }

        return annotationView
    }

    func markerAnnotationView(for marker: MinecraftMapMarkerAnnotation, in mapView: MKMapView) -> MKAnnotationView {
        guard
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: "\(MKMarkerAnnotationView.self)",
                for: marker
            ) as? MKMarkerAnnotationView
        else {
            return MKMarkerAnnotationView()
        }
        view.markerTintColor = marker.color
        view.clusteringIdentifier = marker.clusteringIdentifier
        if let symbol = marker.systemImage {
            #if canImport(AppKit)
                view.glyphImage = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
                view.glyphImage?.isTemplate = true
            #elseif canImport(UIKit)
                view.glyphImage = UIImage(systemName: symbol)?
                    .withRenderingMode(.alwaysTemplate)
            #else
                print("This platform doesn't support SF Symbols.")
            #endif
        }
        return view
    }

    func playerMarkerAnnotationView(
        for player: MinecraftMapPlayerMarkerAnnotation,
        in mapView: MKMapView
    ) -> MKAnnotationView {
        guard let playerMarkerView = mapView.dequeueReusableAnnotationView(
            withIdentifier: "\(MinecraftMapMarkerAnnotationView.self)",
            for: player
        ) as? MinecraftMapMarkerAnnotationView else {
            return MKAnnotationView()
        }
        playerMarkerView.configure(with: player)
        return playerMarkerView
    }
}
