# ``MinecraftMap``

A Minecraft map can be displayed with just a single world:

```swift
MinecraftMap(world: try MinecraftWorld(version: "1.21", seed: 123))
```

Additionally, a center coordinate and dimension can be provided to
customize where the map is:

```swift
@State private var centerCoordinate = CGPoint.zero

MinecraftMap(
    world: try MinecraftWorld(...),
    centerCoordinate: $centerCoordinate,
    dimension: .nether)
```

### Displaying annotations

Much like the `Map` view from SwiftUI, the Minecraft map view supports
displaying markers and annotations. Simply provide the annotations in a
builder block:

```swift
MinecraftMap(world: try MinecraftWorld(version: "1.21", seed: 123)) {
    MinecraftMapMarker(location: .zero, title: "Spawn Point")
    if currentDimension == MinecraftWorld.Dimension.nether {
        MinecraftMapMarker(
            location: CGPoint(x: 11, y: -76),
            title: "XP Farm")
    }
}
```

### Customizing ornaments

Additional controls for zooming the map or displaying a compass are
available through the ``ornaments(_:)`` modifier:

```swift
MinecraftMap(world: try MinecraftWorld(version: "1.21", seed: 123))
    .ornaments(.zoom)
```

### Customizing the color scheme

By default, map views will render using the ``ColorScheme/default`` color
scheme, which is common among tools like Amidst, Cubiomes Viewer,
Chunkbase, and more. This can be changed using the ``mapColorScheme(_:)``
modifier:

```swift
MinecraftMap(world: try MinecraftWorld(version: "1.21", seed: 123))
    .mapColorScheme(.naturalColors)
```

> Note: Changing the map's color scheme is independent of the view's
> preferred scheme, and it will automatically pick the appropriate system
> appearance based on the world dimension.
>
> This behavior can be changed via the
> ``dimensionDeterminesPreferredColorScheme(_:)`` modifier, instead using
> the default ``preferredColorScheme(_:)`` modifier.

## Topics

### Displaying Ornaments

- ``Ornaments``
- ``ornaments(_:)``

### Specifying a Color Scheme

- ``ColorScheme``
- ``mapColorScheme(_:)``
- ``dimensionDeterminesPreferredColorScheme(_:)``
