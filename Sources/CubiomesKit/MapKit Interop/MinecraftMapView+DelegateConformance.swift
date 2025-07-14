//
//  MinecraftMapView+DelegateConformance.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 14-04-2025.
//

import CachingMapKitTileOverlay
import Foundation
import MapKit

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
        return switch overlay {
        case let overlay as any MinecraftTileOverlay:
            CachingTileOverlayRenderer(overlay: overlay)
        default:
            MKOverlayRenderer(overlay: overlay)
        }
    }

    public func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if let marker = annotation as? MinecraftMapMarkerAnnotation {
            guard
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: "\(MKMarkerAnnotationView.self)",
                    for: annotation
                ) as? MKMarkerAnnotationView
            else {
                return MKMarkerAnnotationView()
            }
            configureMarkerAnnotation(marker: marker, view: view)
            return view
        } else if let player = annotation as? MinecraftMapPlayerMarkerAnnotation {
            guard
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: "\(MinecraftPlayerMarkerAnnotationView.self)",
                    for: annotation
                ) as? MinecraftPlayerMarkerAnnotationView
            else {
                return MKMarkerAnnotationView()
            }
            view.configure(withConfiguration: player)
            return view
        }
        return MKAnnotationView()
    }

    func configureMarkerAnnotation(marker: MinecraftMapMarkerAnnotation, view: MKMarkerAnnotationView) {
        view.markerTintColor = marker.color
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
    }
}
