//
//  TransientDrawingCanvas.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 08-12-2025.
//

#if canImport(UIKit)
import PencilKit
import UIKit

class TransientDrawingCanvas: PKCanvasView {
    var allowsDrawing = true

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if !allowsDrawing { return false }
        return super.point(inside: point, with: event)
    }
}
#endif
