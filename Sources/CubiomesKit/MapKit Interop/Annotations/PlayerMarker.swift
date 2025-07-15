//
//  PlayerMarker.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 14-07-2025.
//

import MapKit

/// A marker that displays a player.
///
/// The player marker can be used to show an active player on the map. When the annotation is added to the map view, it
/// will attempt to load in the player's head from the MC-Heads API and use that as the annotation image; otherwise, it
/// will use the default Steve head. Selecting the annotation will display a callout with the player's Minecraft
/// username and their position on the map.
public struct PlayerMarker: MinecraftMapBuilderContent {
    /// The player's location on the map.
    public var location: CGPoint

    /// The player's Minecraft username.
    public var name: String

    /// The player's Minecraft UUID.
    public var playerUUID: UUID

    /// Create a player marker at a specified position.
    /// - Parameter location: The player's location on the map.
    /// - Parameter name: The player's Minecraft username.
    /// - Parameter playerUUID: The player's Minecraft UUID.
    public init(location: CGPoint, name: String, playerUUID: UUID) {
        self.location = location
        self.name = name
        self.playerUUID = playerUUID
    }

    public var content: any MinecraftMapContent {
        MinecraftMapPlayerMarkerAnnotation(playerMarker: self)
    }
}

/// A marker that displays a player.
///
/// The player marker can be used to show an active player on the map. When the annotation is added to the map view, it
/// will attempt to load in the player's head from the MC-Heads API and use that as the annotation image; otherwise, it
/// will use the default Steve head. Selecting the annotation will display a callout with the player's Minecraft
/// username and their position on the map.
public class MinecraftMapPlayerMarkerAnnotation: NSObject, MKAnnotation {
    /// The player's Minecraft username.
    public private(set) var name: String

    /// The player's Minecraft UUID.
    public private(set) var playerUUID: UUID

    /// The player's location on the map in Core Location coordinates.
    public private(set) var coordinate: CLLocationCoordinate2D

    /// The name of the marker.
    public var title: String?

    /// The subtitle of the marker, which displays the marker in Minecraft coordinates.
    public private(set) var subtitle: String?

    /// Create a player marker annotation at a specified position.
    /// - Parameter name: The player's Minecraft username.
    /// - Parameter playerUUID: The player's Minecraft UUID.
    /// - Parameter location: The player's location on the map.
    public init(name: String, playerUUID: UUID, location: CGPoint) {
        self.name = name
        self.playerUUID = playerUUID
        self.coordinate = CLLocationCoordinate2D(projecting: location)

        self.title = name
        let xCoord = Int(location.x)
        let zCoord = Int(location.y)
        self.subtitle = "(\(xCoord), \(zCoord))"
    }

    /// Create a player marker annotation from an existing marker.
    /// - Parameter playerMarker: The player marker to pull data from.
    public init(playerMarker: PlayerMarker) {
        self.name = playerMarker.name
        self.playerUUID = playerMarker.playerUUID
        self.coordinate = CLLocationCoordinate2D(projecting: playerMarker.location)

        self.title = name
        let xCoord = Int(playerMarker.location.x)
        let zCoord = Int(playerMarker.location.y)
        self.subtitle = "(\(xCoord), \(zCoord))"
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let marker = object as? Self else { return false }
        return marker.name == self.name && marker.playerUUID == self.playerUUID && marker.coordinate == self.coordinate
    }
}

extension MinecraftMapPlayerMarkerAnnotation: MinecraftMapContent {
    public var contentType: MinecraftMapContentType { .annotation }
}
