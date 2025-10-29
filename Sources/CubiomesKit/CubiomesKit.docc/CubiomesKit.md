# ``CubiomesKit``

@Metadata {
    @PageImage(purpose: icon, source: "Icon", alt: "The CubiomesKit logo")
    @PageColor(green)
}

Generate, inspect, and view Minecraft Java worlds.

## Overview

With CubiomesKit, you can create and inspect Minecraft Java worlds
programmatically in your macOS, iOS, and iPadOS apps. It leverages the
[Cubiomes](https://github.com/Cubitect/cubiomes) library to facilitate
generation, searches, and rendering map images.

CubiomesKit also supports integration with MapKit to display interactive
maps with markers, annotations and overlays, with support for AppKit/UIKit
and SwiftUI.

![A Minecraft map view in Alidade](Alidade)

> Important: At this time, only worlds generated in Minecraft Java Edition
> are supported.

## Get started with CubiomesKit

CubiomesKit is split up into several packages, each serving their own
purposes:

- **CubiomesKitCore** is the core package for interacting with Minecraft
  worlds.
- **CubiomesMapKit** is the package that provides integrations with MapKit
  to display map views on macOS, iOS, and iPadOS apps.
- **CubiomesKit** is the main package that imports all relevant packages
  for a clean call site in client implementations.

Each provide their own sets of documentation which can be loaded on the
documentation website at https://cubiomeskit.alidade.dev, and they are
listed individually inside the Developer Documentation window in Xcode.

## Topics

### Get started with CubiomesKit

- <doc:MeetCubiomesKit>
- <doc:Changelog>
