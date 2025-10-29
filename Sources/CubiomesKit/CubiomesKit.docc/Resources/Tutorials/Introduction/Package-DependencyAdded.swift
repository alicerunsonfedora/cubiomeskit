// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyCubiomesKitSample",
    products: [
        .library(
            name: "MyCubiomesKitSample",
            targets: ["MyCubiomesKitSample"]
        ),
    ],
    dependencies: [
        .package(url: "https://source.marquiskurt.net/AlidadeMC/cubiomeskit", from: "80f2f5ba38")
    ],
    targets: [
        .target(
            name: "MyCubiomesKitSample"
        ),

    ]
)
