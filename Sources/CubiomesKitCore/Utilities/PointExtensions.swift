//
//  PointExtensions.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 07-04-2025.
//

import Foundation

/// A representation of a Minecraft world coordinate in three-dimensional space.
///
/// The X and Z values refer to the positions along a two-dimensional plane, while the Y value refers to the position
/// along the vertical axis.
public typealias MinecraftPoint = CubiomesKitCore.Point3D<Int32>

extension CGPoint {
    /// Initialize a CGPoint with an existing Minecraft coordinate.
    ///
    /// The X value of the Minecraft coordinate maps to the X value of the CGPoint, while the Z value of the Minecraft
    /// coordinate maps to the Y value of the CGPoint.
    ///
    /// - Parameter minecraftPoint: The Minecraft world coordinate to convert from.
    public init(minecraftPoint: MinecraftPoint) {
        self.init(x: Double(minecraftPoint.x), y: Double(minecraftPoint.z))
    }
}
