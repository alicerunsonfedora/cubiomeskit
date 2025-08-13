//
//  MinecraftMapContentBuilder.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 03-04-2025.
//

import MapKit

public typealias AnyMinecraftMapContent = any MinecraftMapContent

/// A protocol that defines content used in a ``MinecraftMapContentBuilder``.
///
/// This underlying type allows conversion to ``MinecraftMapContent`` which can be handled by map views that support
/// it.
public protocol MinecraftMapBuilderContent {
    /// The built contents of this type.
    var content: any MinecraftMapContent { get }
}

/// A content builder used to generate Minecraft-based map annotations for map views from closures you provide.
@resultBuilder
public struct MinecraftMapContentBuilder {
    public typealias Source = MinecraftMapBuilderContent
    public typealias Destination = AnyMinecraftMapContent

    public static func buildBlock(_ components: Source...) -> [Source] {
        components
    }

    public static func buildBlock(_ components: [Source]...) -> [Source] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: Source) -> [Source] {
        [expression]
    }

    public static func buildExpression(_ expression: [Source]) -> [Source] {
        expression
    }
    
    public static func buildArray(_ components: [[Source]]) -> [Source] {
        components.flatMap({ $0 })
    }

    public static func buildOptional(_ component: [Source]?) -> [Source] {
        component ?? []
    }

    public static func buildEither(first component: [Source]) -> [Source] {
        component
    }

    public static func buildEither(second component: [Source]) -> [Source] {
        component
    }

    public static func buildFinalResult(_ component: [Source]) -> [Destination] {
        component.map(\.content)
    }
}

public func buildMinecraftMapContent(
    @MinecraftMapContentBuilder from contentBuilder: () -> [AnyMinecraftMapContent]
) -> [AnyMinecraftMapContent] {
    return contentBuilder()
}
