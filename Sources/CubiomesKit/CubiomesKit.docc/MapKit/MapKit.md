# MapKit for CubiomesKit

Display and interact with Minecraft world maps using a purpose-built
MapKit view.

## Overview

CubiomesKit provides integration with the MapKit framework to dynamically
display entire Minecraft world maps as map views in your macOS, iOS, and
iPadOS apps. These views support dynamically loading and unloading tiles,
along with displaying markers and annotation represented as Minecraft
coordinates.

A map view can be displayed with either a ``MinecraftMap`` or
``MinecraftMapView``, depending on your app:

@TabNavigator {
    @Tab("SwiftUI") {
        ```swift
        import CubiomesKit
        import SwiftUI
        
        struct MyMapView: View {
            var world: MinecraftWorld
            
            var body: some View {
                MinecraftMap(world) {
                    Marker(location: .zero, title: "Spawn")
                }
                .ornaments(.all)
            }
        }
        ```
    }
    @Tab("AppKit/UIKit") {
        ```swift
        import CubiomesKit
        import UIKit
        
        class MinecraftMapViewController: UIViewController {
            var world: MinecraftWorld
            
            lazy var worldMapView: MinecraftMapView = {
                let mapView = MinecraftMapView(world: world, frame: .zero)
                mapView.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(mapView)
                mapView.mcMapViewDelegate = self
                mapView.ornaments = .all

                let spawnMarker = MinecraftMapMarkerAnnotation(
                    location: .zero, title: "Spawn")
                mapView.addAnnotation(spawnMarker)
                return mapView
            }()
        }
        
        extension MinecraftMapViewController: MinecraftMapViewDelegate {
            ...
        }
        ```
    }
}

## Topics

### Displaying a Map in AppKit/UIKit

- ``MinecraftMapView``
- ``MinecraftMapMarkerAnnotation``

### Displaying a Map in SwiftUI

- ``MinecraftMap``
- ``Marker``
- ``MinecraftMapContentBuilder``

### Point Projections and Conversions

- ``Point3D/init(projectedFrom:)``
- ``CoreLocation/CLLocationCoordinate2D/init(projecting:)``
