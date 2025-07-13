//
//  MinecraftMapView+DelegateConformance.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 14-04-2025.
//

import CachingMapKitTileOverlay
import MapKit
import Foundation

extension MinecraftMapView: MKMapViewDelegate {
    #if os(macOS)
    typealias ImageType = NSImage
    #else
    typealias ImageType = UIImage
    #endif

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
        guard let annotation = annotation as? MinecraftMapMarkerAnnotation else { return MKAnnotationView() }
        guard
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: "\(MKMarkerAnnotationView.self)",
                for: annotation
            ) as? MKMarkerAnnotationView
        else {
            return MKMarkerAnnotationView()
        }

        view.markerTintColor = annotation.color
        if let symbol = annotation.systemImage {
            view.glyphImage = ImageType(systemSymbolName: symbol, accessibilityDescription: nil)
        }
        return view
    }
}
