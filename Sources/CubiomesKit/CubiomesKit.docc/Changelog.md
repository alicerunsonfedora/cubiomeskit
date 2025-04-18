# What's New in CubiomesKit

Review the latest changes made to CubiomesKit.

@Metadata {
    @TitleHeading("Release Notes")
    @PageColor(purple)
}

## 19 April 2025

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
