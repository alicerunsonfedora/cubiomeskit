//
//  CLLocationCoordinate2d+Equatable.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 08-12-2025.
//

import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
