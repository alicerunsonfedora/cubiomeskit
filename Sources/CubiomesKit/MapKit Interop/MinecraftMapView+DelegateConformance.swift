//
//  MinecraftMapView+DelegateConformance.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 14-04-2025.
//

import CachingMapKitTileOverlay
import Foundation
import MapKit

#if os(macOS)
    private typealias ImageType = NSImage
    private typealias ImageViewType = NSImageView
#else
    private typealias ImageType = UIImage
    private typealias ImageViewType = UIImageView
#endif

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
            let view = MKAnnotationView(annotation: player, reuseIdentifier: "PlayerImage")

            fetchAvatar(for: player.playerUUID) { data in
                if let data {
                    DispatchQueue.main.async {
                        view.image = ImageType(data: data)
                    }
                }
            }

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

    private func fetchAvatar(for uuid: UUID, completion: @escaping @Sendable (Data?) -> Void) {
        guard let url = URL(string: "https://mc-heads.net/avatar/\(uuid.uuidString)") else {
            return
        }
        let session = URLSession(configuration: .default)
        let request = URLRequest(url: url)
        session.dataTask(with: request) { [completion] data, response, error in
            guard error == nil else { return }
            completion(data)
        }
    }
}
