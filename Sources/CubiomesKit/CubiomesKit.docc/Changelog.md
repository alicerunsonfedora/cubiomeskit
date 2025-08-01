# What's New in CubiomesKit

Review the latest changes made to CubiomesKit.

@Metadata {
    @TitleHeading("Release Notes")
    @PageColor(purple)
}

## Unreleased

### 1 Aug 2025

#### MapKit Integration

- ``MinecraftMapView`` maps can now provide a preferred configuration
  through the ``MinecraftMapView/mapConfiguration`` property. This
  configuration structure provides configurable map properties such as
  ephemeral rendering and ornaments.
- The ``MinecraftMapView/ornaments`` and
  ``MinecraftMapView/ephemeralRendering`` properties have been deprecated
  in favor of the new ``MinecraftMapView/mapConfiguration`` property.
- By default, maps will pick the appropriate system appearance based on
  the ``MinecraftMapView/dimension``, thereby making the map more
  accessible. This can be configured in the
  ``MinecraftMapView/mapConfiguration`` through the
  ``MinecraftMapPreferredConfiguration/dimensionDeterminesSystemAppearance``
  property.

### 30 July 2025

#### Biome Generation

- Biome generation now occurs on a separate actor. Any public-facing code
  that interfaces with biome generation now works asynchronously to
  prevent data races and crossing actor boundaries.

#### World Rendering

- The `renderSynchronously(inRegion:scale:dimension)` method has been
  removed in favor of a single asynchronous version.

### 28 July 2025

#### MapKit Integration

- The ``MinecraftMapContent`` protocol now includes a typealias for a data
  model that is used to configure the content.
- When updating map content in SwiftUI, it will attempt to update the
  positions of existing player marker annotations instead of rebuilding
  player markers. This should allow developers to display realtime player
  updates with minimal flickering effects.

### 25 July 2025

#### MapKit Integration

- The ``Marker`` and ``MinecraftMapMarkerAnnotation`` annotation types
  now accept a ``Marker/clusteringIdentifier`` property to control
  clustering behaviors.
- Markers are now clustered by default in the map view.
- Player markers are now displayed with a higher priority to ensure they
  remain visible over traditional markers.
- The ``MinecraftMapView`` now supports providing a center coordinate in
  its initializer.

### 15 July 2025

#### MapKit Integration

- The new ``PlayerMarker`` and ``MinecraftMapPlayerMarkerAnnotation``
  marker annotation types allow developers to display Minecraft players
  on the map. Heads of players specified by their Minecraft UUID are
  fetched from the [MC-Heads API](https://mc-heads.net), defaulting to
  Steve if no such UUID exists.
- The CachingMapKitTileOverlay dependency has been update to v1.1.0,
  allowing compilation on Xcode 26 beta and improving general concurrency.
- The Y levels for each dimension has been adjusted to be more accurate to
  the respective sea levels. The Overworld will now render at Y=62, the
  Nether will render at Y=31, and the End will render at Y=48.
- ``MinecraftMapView`` instances that have ephemeral rendering disabled
  should now properly refresh whenever the dimension changes.

#### World Rendering

- The ``MinecraftWorldRenderer`` now uses a new renderer for translating
  biome ID data into appropriate pixel colors, written entirely in Swift.
- The `renderSynchronously(inRegion:scale:dimension)` method has been
  introduced to maintain compatibility with existing codebases that have
  not been rendering their world map content concurrently. This is a
  temporary method that will fold into the general
  ``MinecraftWorldRenderer/render(inRegion:scale:dimension:)`` signature
  for both the synchronous and asynchronous variants.

### 7 June 2025

#### Concurrency

- The new ``MinecraftWorldRendererActor`` is used to isolate rendering
  tasks, thereby improving the performance of rendering maps.

#### MapKit Integration

- ``MinecraftMapView`` now leverages modern Swift concurrency features
  to significantly improve the initial load performance of map tiles.

## 1.0.1 (3 May 2025)

### MapKit Integration

- ``MinecraftMapView`` map views should now properly invalidate the
  rendering cache when the ``MinecraftMapView/renderOptions`` has been
  changed.

## 1.0.0 (19 April 2025)

### MapKit Integration

- For the SwiftUI interoperability, the process for adding, removing, and
  updating map content has been further optimized to ensure that updates
  occur only when necessary, versus all the time.

> Important: ``MinecraftMapContent`` now requires conformance to the
> `Equatable` protocol. For types that inherit or conform to `NSObject`,
> you may need to override `isEqual(_:)` to ensure equality checks operate
> correctly.

## 16 April 2025

### Concurrency

- CubiomesKit now enforces strict Swift concurrency to ensure that it is
  fully compatible for Swift 6 apps and projects. Future iterations of the
  library will focus on improved concurrency with migration to actors and
  more.

### MapKit Integration

- For the SwiftUI interoperability, the process for adding and removing
  map content has changed to minimize flickering.

## 14 April 2025

### MapKit Integration

- The `centerCoordinate` property of the ``MinecraftMap`` should now
  properly relay changes made from the map view back, instead of being
  unchanged.
- The ``MinecraftMapViewDelegate`` exposes the
  ``MinecraftMapViewDelegate/mapViewDidChangeVisibleRegion(_:)-36zql`` to
  respond to the map view's visible region changes.

#### Tile caching and ephemeral rendering

- The ``MinecraftMapView`` and ``MinecraftMap`` will now automatically
  cache rendered tile data instead of re-calculating the data every time
  the renderer requests it. This can be disabled with the
  ``MinecraftMapView/ephemeralRendering`` property.
- The ``MinecraftMapViewDelegate`` includes a new method
  ``MinecraftMapViewDelegate/mapView(_:didChangeEphemeralRendering:)`` to
  listen for when ephemeral rendering was changed.

> Important: Ephemeral rendering cannot be enabled on the ``MinecraftMap``
> SwiftUI view. If you need this functionality in the SwiftUI version,
> create a wrapper around the ``MinecraftMapView`` with the option
> enabled.
