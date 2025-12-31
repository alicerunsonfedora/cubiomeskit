//
//  MinecraftDrawingOverlay.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 08-12-2025.
//

import MapKit
import PencilKit

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
