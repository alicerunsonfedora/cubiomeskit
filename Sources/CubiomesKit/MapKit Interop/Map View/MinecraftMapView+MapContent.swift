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
            if let overlay = content as? MKOverlay {
                addOverlay(overlay)
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

        let managedCollection = ManagedAnnotationCollection(annotations: annotations, contents: contents)
        let counts = managedCollection.countActions()
        logger
            .debug(
                "🗃️ Managed annotations: \(counts.additions) additions, \(counts.inPlaceUpdates) in-place updates, \(counts.deletions) removals"
            )

        for (_, action) in managedCollection {
            switch action {
            case let .addition(managedAnnotation):
                annotationsToAppend.append(managedAnnotation.annotation)
            case let .updateInPlace(managedAnnotation, atIndex):
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
                annotationsToRemove.append(managedAnnotation.annotation)
            }
        }
        addAnnotations(annotationsToAppend)
        removeAnnotations(annotationsToRemove)

        let oldOverlays = self.overlays.filter { !($0 is MinecraftRenderedTileOverlay) }
        removeOverlays(oldOverlays)

        mapContent = contents
    }

    func mapContentNeedsUpdate(_ contents: [any MinecraftMapContent]) -> Bool {
        if contents.count != self.mapContent.count { return true }
        var needsUpdates = false
        for (lhs, rhs) in zip(mapContent, contents) {
            if lhs.equals(other: rhs) { continue }
            needsUpdates = true
            break
        }
        return needsUpdates
    }
}
