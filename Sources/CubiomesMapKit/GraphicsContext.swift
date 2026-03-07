//
//  GraphicsContext.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 07-03-2026.
//

import CoreGraphics

#if canImport(AppKit)
import AppKit

func withGraphicsContext(_ context: CGContext, perform action: @escaping () -> Void) {
    NSGraphicsContext.saveGraphicsState()
    let newContext = NSGraphicsContext(cgContext: context, flipped: true)
    NSGraphicsContext.current = newContext
    action()
    NSGraphicsContext.restoreGraphicsState()
}
#endif

#if canImport(UIKit)
import UIKit

func withGraphicsContext(_ context: CGContext, perform action: @escaping () -> Void) {
    UIGraphicsPushContext(context)
    action()
    UIGraphicsPopContext()
}
#endif
