// swift-tools-version: 6.2

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
    traits: [
        .default(enabledTraits: []),
        .trait(name: "Adwaita", description: "Used to enable Adwaita features.")
    ],
    dependencies: [
        .package(url: "https://github.com/stadiamaps/mapkit-caching-tile-overlay", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0"),
        .package(url: "https://git.aparoksha.dev/aparoksha/adwaita-swift", branch: "main"),
    ],
    targets: [
        .systemLibrary(
            name: "CShumate",
            pkgConfig: "shumate-1.0",
        ),
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
            resources: [
                .process("Resources")
            ]),
        .target(
            name: "CubiomesKitAdwaita",
            dependencies: [
                "CubiomesKitCore",
                .targetItem(name: "CShumate", condition: .when(traits: ["Adwaita"])),
                .product(name: "Adwaita", package: "adwaita-swift", condition: .when(traits: ["Adwaita"])),
                .product(name: "CAdw", package: "adwaita-swift", condition: .when(traits: ["Adwaita"])),
            ]),
        .target(
            name: "CubiomesKit",
            dependencies: [
                "CubiomesKitCore",
                .target(name: "CubiomesKitAdwaita", condition: .when(traits: ["Adwaita"])),
                .target(name: "CubiomesMapKit", condition: .when(platforms: [.macOS, .iOS, .tvOS, .visionOS])),
            ]),
        .executableTarget(
            name: "CubiomesKitAdwaitaDemo",
            dependencies: [
                .product(name: "Adwaita", package: "adwaita-swift", condition: .when(traits: ["Adwaita"])),
                "CubiomesKit",
            ]),
        .testTarget(
            name: "CubiomesKitCoreTests",
            dependencies: [
                "CubiomesKitCore",
            ],
            resources: [
                .process("__Snapshots__")
            ]),
        .testTarget(
            name: "CubiomesMapKitTests",
            dependencies: [
                "CubiomesMapKit",
            ]),
    ]
)

let appleRestrict = ["CubiomesMapKitTests"]
let adwaitaRestrict = ["CubiomesKitAdwaitaDemo"]

#if os(Linux) || os(Windows)
    package.targets.removeAll(where: { appleRestrict.contains($0.name) })
#endif
