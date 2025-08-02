//
//  ManagedAnnotation.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 02-08-2025.
//

import MapKit

enum ManagedAnnotation: Hashable {
    case player(PlayerMarker)
    case marker(Marker)

    var annotation: any MKAnnotation {
        switch self {
        case let .player(model):
            return MinecraftMapPlayerMarkerAnnotation(playerMarker: model)
        case let .marker(model):
            return MinecraftMapMarkerAnnotation(marker: model)
        }
    }
}

enum ManagedAnnotationID: Hashable {
    case player(PlayerMarker.ID)
    case marker(Marker.ID)
}

struct ManagedAnnotationCollection {
    enum Action {
        case addition(ManagedAnnotation)
        case updateInPlace(ManagedAnnotation, atIndex: [any MKAnnotation].Index)
        case remove(ManagedAnnotation)
    }

    struct Count {
        var additions: Int
        var inPlaceUpdates: Int
        var deletions: Int
    }

    private var annotationLUT: [ManagedAnnotationID: Action]

    init(annotations: [any MKAnnotation] = [], contents: [any MinecraftMapContent] = []) {
        annotationLUT = [:]
        zip(annotations: annotations, contents: contents)
    }

    func countActions() -> Count {
        var counts = Count(additions: 0, inPlaceUpdates: 0, deletions: 0)
        for (_, value) in annotationLUT {
            switch value {
            case .addition:
                counts.additions += 1
            case .updateInPlace:
                counts.inPlaceUpdates += 1
            case .remove:
                counts.deletions += 1
            }
        }
        return counts
    }

    mutating func zip(annotations: [any MKAnnotation], contents: [any MinecraftMapContent]) {
        // Phase one: assume we need to add entirely new content.
        for content in contents {
            if let player = content.model as? PlayerMarker {
                annotationLUT[.player(player.id)] = .addition(.player(player))
            } else if let marker = content.model as? Marker {
                annotationLUT[.marker(marker.id)] = .addition(.marker(marker))
            } else {
                continue
            }
        }

        // Phase two: check if we can update in place. Also mark any mismatching annotations as queued for deletion.
        for (index, annotation) in annotations.enumerated() {
            if let player = annotation as? MinecraftMapPlayerMarkerAnnotation {
                let key = ManagedAnnotationID.player(player.model.id)
                if let existingKey = annotationLUT[key] {
                    switch existingKey {
                    case let .addition(model):
                        annotationLUT[key] = .updateInPlace(model, atIndex: index)
                    default:
                        annotationLUT[key] = .updateInPlace(.player(player.model), atIndex: index)
                    }
                } else {
                    annotationLUT[key] = .remove(.player(player.model))
                }
            } else if let marker = annotation as? MinecraftMapMarkerAnnotation {
                let key = ManagedAnnotationID.marker(marker.model.id)
                if let existingKey = annotationLUT[key] {
                    switch existingKey {
                    case let .addition(model):
                        annotationLUT[key] = .updateInPlace(model, atIndex: index)
                    default:
                        annotationLUT[key] = .updateInPlace(.marker(marker.model), atIndex: index)
                    }
                } else {
                    annotationLUT[key] = .remove(.marker(marker.model))
                }
            } else {
                continue
            }
        }
    }
}

extension ManagedAnnotationCollection: Collection {
    typealias Key = ManagedAnnotationID
    typealias Value = Action
    typealias Element = (Key, Value)
    typealias Index = Dictionary<Key, Value>.Index

    var startIndex: Index { annotationLUT.startIndex }
    var endIndex: Index { annotationLUT.endIndex }

    func index(after index: Index) -> Index {
        annotationLUT.index(after: index)
    }

    subscript(position: Index) -> (Key, Value) {
        annotationLUT[position]
    }
}
