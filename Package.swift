// swift-tools-version: 6.0

import PackageDescription

// Allow integers to wrap to mimic Java behaviors.
private let wrapIntegers = CSetting.unsafeFlags(["-fwrapv"])

// Ignore implicit conversions inside of Cubiomes, since this is upstream code.
private let ignoreCubiomes = [
    "-Wno-implicit-int",
    "-Wno-implicit-function-declaration",
    "-Wno-conversion",
]

let package = Package(
    name: "CubiomesKit",
    platforms: [.macOS(.v13), .iOS(.v16), .visionOS(.v1), .watchOS(.v9)],
    products: [
        .library(
            name: "CubiomesKit",
            targets: ["CubiomesKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/stadiamaps/mapkit-caching-tile-overlay", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "Cubiomes",
            exclude: ["docs", "tests.c"],
            publicHeadersPath: ".",
            cSettings: [wrapIntegers, .unsafeFlags(ignoreCubiomes)]),
        .target(
            name: "CubiomesInternal",
            dependencies: ["Cubiomes"],
            publicHeadersPath: ".",
            cSettings: [wrapIntegers, .unsafeFlags(ignoreCubiomes)]),
        .target(
            name: "CubiomesKitCore",
            dependencies: [
                "Cubiomes",
                "CubiomesInternal",
            ],
            resources: [
                .process("Resources")
            ]),
        .target(
            name: "CubiomesMapKit",
            dependencies: [
                "CubiomesKitCore",
                .product(name: "CachingMapKitTileOverlay", package: "mapkit-caching-tile-overlay"),
            ],
        ),
        .target(
            name: "CubiomesKit",
            dependencies: [
                "CubiomesKitCore",
                .target(name: "CubiomesMapKit", condition: .when(platforms: [.macOS, .iOS, .tvOS, .visionOS])),
            ],
        ),
        .testTarget(
            name: "CubiomesKitTests",
            dependencies: [
                "CubiomesKit",
            ],
            resources: [
                .process("__Snapshots__")
            ],
        ),
    ]
)
