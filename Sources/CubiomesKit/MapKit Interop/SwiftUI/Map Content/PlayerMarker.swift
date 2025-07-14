//
//  PlayerMarker.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 14-07-2025.
//

import MapKit

public struct PlayerMarker: MinecraftMapBuilderContent {
    public var location: CGPoint
    public var name: String
    public var playerUUID: UUID

    public init(location: CGPoint, name: String, playerUUID: UUID) {
        self.location = location
        self.name = name
        self.playerUUID = playerUUID
    }

    public var content: any MinecraftMapContent {
        MinecraftMapPlayerMarkerAnnotation(playerMarker: self)
    }
}

public class MinecraftMapPlayerMarkerAnnotation: NSObject, MKAnnotation {
    public private(set) var name: String
    public private(set) var playerUUID: UUID
    public private(set) var coordinate: CLLocationCoordinate2D

    /// The name of the marker.
    public var title: String?

    /// The subtitle of the marker, which displays the marker in Minecraft coordinates.
    public private(set) var subtitle: String?

    public init(name: String, playerUUID: UUID, location: CGPoint) {
        self.name = name
        self.playerUUID = playerUUID
        self.coordinate = CLLocationCoordinate2D(projecting: location)

        self.title = name
        let xCoord = Int(location.x)
        let zCoord = Int(location.y)
        self.subtitle = "(\(xCoord), \(zCoord))"
    }

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
