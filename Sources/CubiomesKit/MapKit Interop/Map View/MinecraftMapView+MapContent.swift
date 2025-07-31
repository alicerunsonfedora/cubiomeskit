//
//  MinecraftMapView+MapContent.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 31-07-2025.
//

import CubiomesInternal
import MapKit

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
        let isInitialPass = annotations.isEmpty

        let oldOverlays = self.overlays.filter { !($0 is MinecraftRenderedTileOverlay) }
        let playerMapping = createPlayerMap(from: contents)
        var annotationsToRemove = [any MKAnnotation]()

        // First pass: Prefer to update any existing annotations instead of queuing for removal.
        for annotation in annotations {
            if let player = annotation as? MinecraftMapPlayerMarkerAnnotation {
                if let newLocation = playerMapping[player.model.playerUUID] {
                    player.model.location = newLocation
                    continue
                }
                annotationsToRemove.append(annotation)
            } else {
                annotationsToRemove.append(annotation)
            }
        }

        // Second pass: Add any map content that wasn't accounted for in the first pass.
        for content in contents {
            if isInitialPass {
                self.addMapContent(content)
                continue
            }
            if let player = content as? MinecraftMapPlayerMarkerAnnotation,
                playerMapping[player.model.playerUUID] != nil
            {
                continue
            }
            self.addMapContent(content)
        }

        removeAnnotations(annotationsToRemove)
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

    func createPlayerMap(from contents: [any MinecraftMapContent]) -> [UUID: CGPoint] {
        var coordinates = [UUID: CGPoint]()
        for content in contents {
            if content.contentType == .annotation, let player = content.model as? PlayerMarker {
                coordinates[player.playerUUID] = player.location
            }
        }
        return coordinates
    }
}
