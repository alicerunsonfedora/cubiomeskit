//
//  TestFixtures.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 01-08-2025.
//

import Testing

extension Tag {
    /// Tests that pertain to the MapKit integration.
    @Tag static var mapkit: Self

    /// Tests that involve manipulating biome data.
    @Tag static var biomes: Self

    /// Tests that involve rendering world information.
    @Tag static var render: Self
}
