//
//  MapKit+CodableTests.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 08-12-2025.
//

import MapKit
import Testing

@testable import CubiomesMapKit

struct CodableMapKitTests {
    private let sampleCoordinate = CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988)
    private let sampleRect = MKMapRect(x: 37.334886, y: -122.008988, width: 512, height: 512)
    
    @Test("CLLocationCoordinate2D (Decode)", .tags(.mapkit))
    func coordinateDecode() async throws {
        let sampleCoordinateData =
            """
            { "latitude": 37.334886, "longitude": -122.008988 }
            """
        let data = try #require(sampleCoordinateData.data(using: .utf8))
        let decoder = JSONDecoder()
        let coordinate = try decoder.decode(CLLocationCoordinate2D.self, from: data)
        #expect(coordinate == sampleCoordinate)
    }

    @Test("CLLocationCoordinate2D (Encode)", .tags(.mapkit))
    func coordinateEncode() async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        let data = try encoder.encode(sampleCoordinate)
        let text = try #require(String(data: data, encoding: .utf8))
        #expect(text == "{\"latitude\":37.334886,\"longitude\":-122.008988}")
    }

    @Test("MKMapRect (Decode)", .tags(.mapkit))
    func mapRectDecode() async throws {
        let sampleRectData =
            """
            {
                "originX": 37.334886,
                "originY": -122.008988,
                "width": 512.0,
                "height": 512.0
            }
            """
        let data = try #require(sampleRectData.data(using: .utf8))
        let decoder = JSONDecoder()
        let rect = try decoder.decode(MKMapRect.self, from: data)
        #expect(rect.origin.x == sampleRect.origin.x)
        #expect(rect.origin.y == sampleRect.origin.y)
        #expect(rect.size.width == sampleRect.size.width)
        #expect(rect.size.height == sampleRect.size.height)
    }

    @Test("MKMapRect (Encode)", .tags(.mapkit))
    func mapRectEncode() async throws {
        let sampleRectData =
            """
            {"height":512,"originX":37.334886,"originY":-122.008988,"width":512}
            """

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let data = try encoder.encode(sampleRect)
        let text = try #require(String(data: data, encoding: .utf8))
        #expect(text == sampleRectData)
    }
}
