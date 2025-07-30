//
//  CubiomesRangeExtensions.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 30-07-2025.
//

import CubiomesInternal

extension CubiomesInternal.Range {
    init(rect: MinecraftWorldRect) {
        self.init(
            scale: rect.mapScale.rawValue,
            x: rect.origin.x,
            z: rect.origin.z,
            sx: rect.size.length,
            sz: rect.size.width,
            y: rect.origin.y,
            sy: rect.size.height
        )
    }
}
