//
//  MinecraftMapDrawingOverlayRenderer.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 08-12-2025.
//

import MapKit
import PencilKit

class MinecraftMapDrawingOverlayRenderer: MKOverlayRenderer {
    var model: MinecraftMapDrawing

    init(model: MinecraftMapDrawing) {
        self.model = model
        super.init(overlay: MinecraftDrawingOverlay(model: model))
    }

    init(overlay: MinecraftDrawingOverlay) {
        self.model = overlay.model
        super.init(overlay: overlay)
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let rect = self.rect(for: model.mapRect)
        let drawing = model.drawing

        #if canImport(UIKit)
            UIGraphicsPushContext(context)
        #elseif canImport(AppKit)
            NSGraphicsContext.saveGraphicsState()
            let newContext = NSGraphicsContext(cgContext: context, flipped: false)
        #endif

        drawing.image(from: drawing.bounds, scale: contentScaleFactor).draw(in: rect)

        #if canImport(UIKit)
            UIGraphicsPopContext()
        #elseif canImport(AppKit)
            NSGraphicsContext.restoreGraphicsState()
        #endif
    }
}
