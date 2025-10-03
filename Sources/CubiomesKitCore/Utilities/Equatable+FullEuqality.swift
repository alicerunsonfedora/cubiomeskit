//
//  Equatable+FullEuqality.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 19-04-2025.
//

import Foundation

extension Equatable {
    /// Checks whether two items are equal to each other.
    ///
    /// This shouldn't really be used _unless_ you are having issues with standard equality checks, such as with the
    /// ``MinecraftMapContent`` protocol.
    func equals(other: any Equatable) -> Bool {
        if let nsObject = self as? NSObject {
            return nsObject.isEqual(other as? NSObject)
        }
        return self == other as? Self
    }
}
