# What's New in CubiomesKit

Review the latest changes made to CubiomesKit.

@Metadata {
    @TitleHeading("Release Notes")
    @PageColor(purple)
}

## 14 April 2025

### MapKit Integration

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
