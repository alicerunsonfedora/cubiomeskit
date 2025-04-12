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

## Topics

### Generating Minecraft Worlds

Generate Minecraft worlds with a given version and seed.

- ``MinecraftWorld``
- ``MinecraftVersion``

### Querying World Information

Query information about a Minecraft world, such as nearby biomes and
structures.

- ``MinecraftBiome``
- ``MinecraftBiomeSearching``
- ``MinecraftStructure``
- ``MinecraftStructureSearching``

### Rendering Map Tiles

Render map images of Minecraft worlds.

- ``MinecraftWorldRenderer``
- ``PPMData``

### MapKit Integration

- <doc:MapKit> 

### Point and Space Representations

- ``Point3D``
- ``MinecraftPoint``
- ``MinecraftWorldRect``
