//
//  MinecraftMapPreferredConfiguration.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 01-08-2025.
//

import CubiomesInternal
import CubiomesKitCore
import Foundation

/// A structure used to configure a ``MinecraftMapView``.
public struct MinecraftMapPreferredConfiguration {
    /// A set of views and controls that sit above the map.
    public struct Ornaments: OptionSet, Sendable {
        /// The raw value of the option set.
        public let rawValue: Int

        /// Display the map compass.
        public static let compass = Ornaments(rawValue: 1 << 0)

        /// Display controls for zooming in and out of the map.
        public static let zoom = Ornaments(rawValue: 1 << 1)

        /// Display a map scale ornament.
        ///
        /// This ornament is generally used to display a scale control that represents the scale of a map in meters.
        ///
        /// - Note: This view might be inaccurate regarding scaling.
        public static let scale = Ornaments(rawValue: 1 << 2)

        /// Display all available ornaments.
        public static let all: Ornaments = [.compass, .zoom, .scale]

        /// Initializes an ornament option.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    public enum PencilKitSupport: Sendable, ExpressibleByBooleanLiteral, Equatable {
        case enabled(autoclear: Bool, autosubmit: Bool)
        case disabled

        public init(booleanLiteral value: BooleanLiteralType) {
            switch value {
            case true:
                self = .enabled(autoclear: true, autosubmit: false)
            case false:
                self = .disabled
            }
        }
    }

    /// Whether to let users draw on the map through PencilKit.
    public var allowPencilKitDrawings: PencilKitSupport = false

    /// Whether the current world dimension determines the appropriate system appearance for the map view.
    ///
    /// Some world dimensions such as the overworld might provide inaccessible experiences when using the default
    /// system appearance. Enabling this property will let the map view automatically determine the appropriate system
    /// appearance for the map view based on the dimension.
    public var dimensionDeterminesSystemAppearance: Bool

    /// Whether Minecraft map tiles should be rendered ephemerally (i.e., without caching).
    ///
    /// By default, the tile overlay renderer will create and use a cache to store generated tiles to improve
    /// performance, rather than regenerating the tile every time it is requested. However, this behavior can be
    /// disabled for debugging purposes or for other reasons.
    ///
    /// - Note: This option will always return false in the ``MinecraftMap`` view. If you need the SwiftUI view to
    ///   leverage ephemeral rendering, create a wrapper around ``MinecraftMapView``.
    /// - Important: To improve performance in your apps, it is recommended to keep this option disabled.
    public var ephemeralRendering: Bool

    /// The ornaments that should be displayed on the map.
    ///
    /// Ornaments include standard map controls for zooming, rotation, and a compass.
    public var ornaments: Ornaments

    /// Create a preferred configuration.
    /// - Parameter dimensionDeterminesSystemAppearance: Whether the world dimension determines the system appearance
    ///   to use.
    /// - Parameter ephemeralRendering: Whether to use ephemeral rendering.
    /// - Parameter ornaments: The ornaments that should be displayed on the map.
    public init(
        allowDrawingWithPencilKit: PencilKitSupport = false,
        dimensionDeterminesSystemAppearance: Bool,
        ephemeralRendering: Bool,
        ornaments: Ornaments
    ) {
        self.allowPencilKitDrawings = allowDrawingWithPencilKit
        self.dimensionDeterminesSystemAppearance = dimensionDeterminesSystemAppearance
        self.ephemeralRendering = ephemeralRendering
        self.ornaments = ornaments
    }
}

public extension MinecraftMapPreferredConfiguration {
    /// The default preferred configuration.
    static func preferredDefault() -> Self {
        MinecraftMapPreferredConfiguration(
            allowDrawingWithPencilKit: false,
            dimensionDeterminesSystemAppearance: true,
            ephemeralRendering: false,
            ornaments: [.compass]
        )
    }
}
