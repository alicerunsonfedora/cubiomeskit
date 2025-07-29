//
//  MinecraftMapView+MapContent.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 29-07-2025.
//

import MapKit
import SwiftUI

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
        let playerMapping = createPlayerMap(from: contents)
        let markerMapping = createMarkerMap(from: contents)
        var updatedAnnotations = [String: Bool]()

        var annotationsToRemove = [any MKAnnotation]()

        // First pass: Prefer to update any existing annotations instead of queuing for removal.
        for annotation in annotations {
            if let player = annotation as? MinecraftMapPlayerMarkerAnnotation {
                if let newLocation = playerMapping[player.model.playerUUID] {
                    if player.model.location != newLocation {
                        player.model.location = newLocation
                        updatedAnnotations[player.model.playerUUID.uuidString] = true
                    }
                    continue
                }
                annotationsToRemove.append(annotation)
            } else if let marker = annotation as? MinecraftMapMarkerAnnotation {
                if let newModel = markerMapping[marker.id] {
                    if marker.model != newModel {
                        marker.model = newModel
                        updatedAnnotations[marker.id] = true
                    }
                    continue
                }
                annotationsToRemove.append(annotation)
            } else {
                annotationsToRemove.append(annotation)
            }
        }

        // Second pass: Add any map content that wasn't accounted for in the first pass.
        let isInitialPass = annotations.isEmpty
        for content in contents {
            if isInitialPass {
                self.addMapContent(content)
                continue
            }

            if let player = content as? MinecraftMapPlayerMarkerAnnotation {
                if playerMapping[player.model.playerUUID] != nil,
                   updatedAnnotations[player.model.playerUUID.uuidString] == true {
                    continue
                }
                self.addMapContent(content)
            } else if let marker = content as? MinecraftMapMarkerAnnotation {
                if markerMapping[marker.model.id] != nil, updatedAnnotations[marker.id] == true {
                    continue
                }
                self.addMapContent(content)
            } else {
                self.addMapContent(content)
            }
        }

        removeAnnotations(annotationsToRemove)
    }

    func updateOverlays(from contents: [any MinecraftMapContent]) {
        let oldOverlays = self.overlays.filter { !($0 is MinecraftRenderedTileOverlay) }
        for content in contents where content.contentType == .overlay {
            self.addMapContent(content)
        }
        removeOverlays(oldOverlays)
    }
}

