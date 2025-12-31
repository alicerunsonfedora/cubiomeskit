//
//  MapKit+Codable.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 08-12-2025.
//

import MapKit

extension MKMapRect: @retroactive Codable {
    enum CodingKeys: String, CodingKey {
        case originX
        case originY
        case width
        case height
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let originX = try container.decode(Double.self, forKey: .originX)
        let originY = try container.decode(Double.self, forKey: .originY)
        let width = try container.decode(Double.self, forKey: .width)
        let height = try container.decode(Double.self, forKey: .height)

        self.init(x: originX, y: originY, width: width, height: height)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(origin.x, forKey: .originX)
        try container.encode(origin.y, forKey: .originY)
        try container.encode(size.width, forKey: .width)
        try container.encode(size.height, forKey: .height)
    }
}

extension CLLocationCoordinate2D: @retroactive Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)

        self.init(latitude: latitude, longitude: longitude)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
