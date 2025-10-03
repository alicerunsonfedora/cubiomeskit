//
//  MinecraftWorldRendererActor.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 07-06-2025.
//

/// A global actor used to handle world rendering tasks.
///
/// When attempting to render tiles, appropriate functions and tasks should respect this actor's boundary:
///
/// ```swift
/// @MainActor
/// func doSomething(for world: MinecraftWorld) async throws -> Data {
///    let renderer = await MinecraftWorldRenderer(world: world, options: renderingOptions)
///    return await renderer.render(inRegion: chunk, scale: 1, dimension: dimension)
/// }
/// ```
@globalActor public actor MinecraftWorldRendererActor {
    /// The shared instance of the rendering actor.
    public static let shared = MinecraftWorldRendererActor()
}
