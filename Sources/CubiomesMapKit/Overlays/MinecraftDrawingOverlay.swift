//
//  MinecraftDrawingOverlay.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 08-12-2025.
//

import MapKit
import PencilKit

public struct MinecraftDrawing: MinecraftMapBuilderContent {
    public var model: MinecraftMapDrawing

    public init(model: MinecraftMapDrawing) {
        self.model = model
    }

    public init(drawing: PKDrawing, location: CLLocationCoordinate2D, bounds: MKMapRect) {
        self.model = MinecraftMapDrawing(drawing: drawing, location: location, mapRect: bounds)
    }

    public var content: any MinecraftMapContent {
        MinecraftDrawingOverlay(model: model)
    }
}

public class MinecraftDrawingOverlay: NSObject, MKOverlay {
    public var model: MinecraftMapDrawing {
        didSet {
            self.coordinate = model.location
            self.boundingMapRect = model.mapRect
        }
    }

    public var coordinate: CLLocationCoordinate2D
    public var boundingMapRect: MKMapRect

    public init(model: MinecraftMapDrawing) {
        self.model = model
        self.coordinate = model.location
        self.boundingMapRect = model.mapRect
    }
}

extension MinecraftDrawingOverlay: MinecraftMapContent {
    public var contentType: MinecraftMapContentType { .overlay }
}
