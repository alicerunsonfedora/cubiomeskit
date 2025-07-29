//
//  MinecraftMapView+MapContent.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 29-07-2025.
//

import MapKit
import SwiftUI

private enum Either<T, U> {
    case left(T)
    case right(U)
}

private struct AnnotationUpdate {
    enum UpdateType {
        case addition, inPlace, removal
    }
    var content: Either<any MinecraftMapContent, any MKAnnotation>
    var action: UpdateType
    var updateIndex: Int?
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
        if !mapContentNeedsUpdate(contents) { return }

        updateAnnotations(from: contents)
        updateOverlays(from: contents)
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

    func createPlayerMap(from contents: [any MinecraftMapContent]) -> [UUID: CGPoint] {
        var coordinates = [UUID: CGPoint]()
        for content in contents {
            if content.contentType == .annotation, let player = content.model as? PlayerMarker {
                coordinates[player.playerUUID] = player.location
            }
        }
        return coordinates
    }

    func createMarkerMap(from contents: [any MinecraftMapContent]) -> [String: Marker] {
        var markers = [String: Marker]()
        for content in contents {
            if content.contentType == .annotation, let marker = content.model as? Marker {
                markers[marker.id] = marker
            }
        }
        return markers
    }

    func updateAnnotations(from contents: [any MinecraftMapContent]) {
        var updateTransaction = [String: AnnotationUpdate]()

        // Phase one: assume we're adding all new content.
        for content in contents where content.contentType == .annotation {
            let updateID = identifier(for: content)
            updateTransaction[updateID] = AnnotationUpdate(content: .left(content), action: .addition)
        }

        // Phase two: check for any cases where we can perform an in-place update. Fall back to removal when
        // necessary.
        for (index, annotation) in annotations.enumerated() {
            let updateID = identifier(for: annotation)
            if var update = updateTransaction[updateID] {
                update.action = .inPlace
                update.updateIndex = index
                updateTransaction[updateID] = update
            } else {
                updateTransaction[updateID] = AnnotationUpdate(content: .right(annotation), action: .removal)
            }
        }

        // Phase three: Handle in-place updates.
        for (_, updateCtx) in updateTransaction {
            guard updateCtx.action == .inPlace, let idx = updateCtx.updateIndex else {
                continue
            }

            guard case .left(let content) = updateCtx.content else { continue }
            let annotation = annotations[idx]
            if let playerA = annotation as? MinecraftMapPlayerMarkerAnnotation,
               let playerC = content.model as? PlayerMarker {
                playerA.model = playerC
            } else if let markerA = annotation as? MinecraftMapMarkerAnnotation,
                      let markerC = content.model as? Marker {
                markerA.model = markerC
            }
        }

        // Phase four: handle remaining transaction types.
        for (_, updateCtx) in updateTransaction {
            switch (updateCtx.action, updateCtx.content) {
            case let (.addition, .left(content)):
                self.addMapContent(content)
            case let (.removal, .right(annotation)):
                self.removeAnnotation(annotation)
            default:
                continue
            }
        }
    }

    func identifier(for content: any MinecraftMapContent) -> String {
        if let playerID = content.model as? PlayerMarker {
            return playerID.playerUUID.uuidString
        } else if let marker = content.model as? Marker {
            return marker.id
        } else {
            return ""
        }
    }

    func identifier(for annotation: any MKAnnotation) -> String {
        guard let content = annotation as? any MinecraftMapContent else {
            return ""
        }
        return self.identifier(for: content)
    }

    func updateOverlays(from contents: [any MinecraftMapContent]) {
        let oldOverlays = self.overlays.filter { !($0 is MinecraftRenderedTileOverlay) }
        for content in contents where content.contentType == .overlay {
            self.addMapContent(content)
        }
        removeOverlays(oldOverlays)
    }
}

