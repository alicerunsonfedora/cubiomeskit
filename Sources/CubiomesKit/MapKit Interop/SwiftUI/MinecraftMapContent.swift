//
//  MinecraftMapContent.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 09-04-2025.
//

import MapKit
import SwiftUI

/// An enumeration of the supported content types for Minecraft map content.
public enum MinecraftMapContentType {
    /// An annotation, which acts as an indicator or a point of interest.
    ///
    /// > Important: Map content with this type should conform to the `MKAnnotation` protocol.
    case annotation

    /// An overlay, which provides a shape.
    ///
    /// > Important: Map content with this type should conform to the `MKOverlay` protocol.
    case overlay
}

/// A protocol that defines map content that can be added to a ``MinecraftMapView``.
public protocol MinecraftMapContent: Equatable, Hashable {
    associatedtype Model: Equatable, Hashable, Identifiable

    /// The type of content to be added to the map.
    var contentType: MinecraftMapContentType { get }

    /// The model used to configure the annotation or overlay.
    var model: Model { get set }
}
