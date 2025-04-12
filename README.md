# CubiomesKit

Create, inspect, and view Minecraft worlds in your macOS, iOS, and iPadOS
apps.

With CubiomesKit, you can create and inspect Minecraft Java worlds
programmatically in your macOS, iOS, and iPadOS apps. It leverages the
[Cubiomes](https://github.com/Cubitect/cubiomes) library to facilitate
generation, searches, and rendering map images.

CubiomesKit also supports integration with MapKit to display interactive
maps, with support for AppKit/UIKit and SwiftUI.

> Important: At this time, only words generated in Minecraft Java Edition
> are supported.

## Getting started

### Support

CubiomesKit guarantees support for the following platforms:

- macOS Ventura (13.0) or later
- iOS 16 or later
- tvOS 16 or later
- watchOS 8 or later

### Getting started

To add the package as a dependency to your project, add the following to
your Package.swift:

<!-- TODO: Point this to a stable release soon. -->

```swift
dependencies: [
    .package(url: "https://github.com/alicerunsonfedora/cubiomesKit",
             branch: "main")
]
```

Or go to **File -> Add Package Dependencies...** in Xcode to add the
dependency.

## License

CubiomesKit is free and open-source software licensed under the Mozilla
Public License, v2.

