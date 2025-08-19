//
//  MinecraftMapView+MapContent.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 31-07-2025.
//

import CubiomesInternal
import MapKit

public protocol ModeledAnnotation: MKAnnotation {
    associatedtype Model: Equatable, Hashable, Identifiable

    var model: Model { get set }
}

extension ModeledAnnotation {
    public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else { return false }
        return other.model == self.model
    }
}

extension MinecraftMapView {
    func addMapContent(_ content: any MinecraftMapContent) {
        switch content.contentType {
        case .annotation:
            if let annotation = content as? MKAnnotation {
                addAnnotation(annotation)
            }
        case .overlay:
            if let polyline = content as? MinecraftPolyline {
                addOverlay(polyline.polyline, level: .aboveLabels)
            } else if let overlay = content as? MKOverlay {
                addOverlay(overlay, level: .aboveLabels)
            }
        }
    }

    func addMapContents(_ contents: [any MinecraftMapContent]) {
        for content in contents {
            addMapContent(content)
        }
    }

    func removeMapContent(_ content: any MinecraftMapContent) {
        switch content.contentType {
        case .annotation:
            if let annotation = content as? MKAnnotation {
                removeAnnotation(annotation)
            }
        case .overlay:
            if let overlay = content as? MKOverlay {
                removeOverlay(overlay)
            }
        }
    }

    func resyncMapContentIfNeeded(_ contents: [any MinecraftMapContent]) {
        guard mapContentNeedsUpdate(contents) else { return }
        var annotationsToAppend = [any MKAnnotation]()
        var annotationsToRemove = [any MKAnnotation]()

        let clusters = annotations.filter { $0 is MKClusterAnnotation }
        removeAnnotations(clusters)

        let managedCollection = ManagedAnnotationCollection(annotations: annotations, contents: contents)
        let counts = managedCollection.countActions()
        logger.debug("🗃️ Managed annotations: \(counts.formatted())")

        for (_, action) in managedCollection {
            switch action {
            case .ignore:
                break
            case let .addition(managedAnnotation):
                if annotations.contains(where: { $0.isEqual(managedAnnotation.annotation) }) {
                    logger.error("🗃️ The specified annotation already exists.")
                    continue
                }
                annotationsToAppend.append(managedAnnotation.annotation)
            case let .updateInPlace(managedAnnotation, atIndex):
                guard annotations.indices.contains(atIndex) else {
                    logger.error(
                        "🗃️ The managed annotation doesn't exist at index \(atIndex). Did you prematurely remove it?")
                    continue
                }
                switch managedAnnotation {
                case let .player(playerModel):
                    if let annotation = annotations[atIndex] as? MinecraftMapPlayerMarkerAnnotation {
                        annotation.model = playerModel
                    }
                case let .marker(markerModel):
                    if let annotation = annotations[atIndex] as? MinecraftMapMarkerAnnotation {
                        annotation.model = markerModel
                    }
                }
            case let .remove(managedAnnotation):
                // NOTE(alicerunsonfedora): I don't really like doing this, since removals are now an O(n^2) operation,
                // but oh well...
                for annotation in annotations {
                    if !annotation.isEqual(managedAnnotation.annotation) {
                        continue
                    }
                    annotationsToRemove.append(annotation)
                }
            }
        }
        addAnnotations(annotationsToAppend)
        removeAnnotations(annotationsToRemove)

        let oldOverlays = self.overlays.filter { !($0 is MinecraftRenderedTileOverlay) }
        removeOverlays(oldOverlays)

        for overlay in contents where overlay.contentType == .overlay {
            if let polyline = overlay as? MinecraftPolyline {
                addOverlay(polyline.polyline, level: .aboveLabels)
            }
        }

        mapContent = contents
    }

    func mapContentNeedsUpdate(_ contents: [any MinecraftMapContent]) -> Bool {
        if contents.count != self.mapContent.count { return true }
        let currentManagedConfiguration = ManagedAnnotationCollection(
            annotations: self.annotations,
            contents: self.mapContent
        )
        let newManagedConfiguration = ManagedAnnotationCollection(annotations: self.annotations, contents: contents)
        return newManagedConfiguration != currentManagedConfiguration
    }
}
