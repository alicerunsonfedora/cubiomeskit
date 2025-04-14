//
//  MinecraftMapViewDelegate.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 14-04-2025.
//

import MapKit
import Foundation

/// A delegate used to handle interactions and events from a ``MinecraftMapView``.
///
/// This is intended to be used as a replacement for an `MKMapViewDelegate`, as ``MinecraftMapView``s already define a
/// delegate to display Minecraft tiles.
public protocol MinecraftMapViewDelegate: AnyObject {
    /// An event that occurs when the view region has been changed.
    ///
    /// - Parameter mapView: The Minecraft map view that changed the region.
    /// - Parameter animated: Whether the change was animated.
    func mapView(_ mapView: MinecraftMapView, regionDidChangeAnimated animated: Bool)

    /// An event that occurs when an annotation view has been selected.
    ///
    /// - Parameter mapView: The Minecraft map view that changed the region.
    /// - Parameter view: The annotation view that was selected.
    func mapView(_ mapView: MinecraftMapView, didSelect view: MKAnnotationView)

    /// An event that occurs when the map has changed the ephemeral rendering property.
    ///
    /// - Parameter mapView: The Minecraft map view that changed the ephemeral rendering.
    /// - Parameter ephemeral: Whether ephemeral rendering was enabled.
    func mapView(_ mapView: MinecraftMapView, didChangeEphemeralRendering ephemeral: Bool)

    /// An event that occurs when the map's visible region has changed.
    ///
    /// - Parameter mapView: The Minecraft map view that had its visible region changed.
    func mapViewDidChangeVisibleRegion(_ mapView: MinecraftMapView)
}

extension MinecraftMapViewDelegate {
    public func mapView(_ mapView: MinecraftMapView, regionDidChangeAnimated animated: Bool) {}
    public func mapView(_ mapView: MinecraftMapView, didSelect view: MKAnnotationView) {}
    public func mapView(_ mapView: MinecraftMapView, didChangeEphemeralRendering ephemeral: Bool) {}
    public func mapViewDidChangeVisibleRegion(_ mapView: MinecraftMapView) {}
}
