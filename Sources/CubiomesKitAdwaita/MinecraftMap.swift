import Adwaita
import CShumate
import CubiomesKitCore
import Foundation

public struct MinecraftMap: AdwaitaWidget {
    public init() {}

    public func initializeWidget() -> Any {
        let map = shumate_simple_map_new() as OpaquePointer?
        let registry = shumate_map_source_registry_new_with_defaults()
        let source = shumate_map_source_registry_get_by_id(registry, SHUMATE_MAP_SOURCE_OSM_MAPNIK)
        shumate_simple_map_set_map_source(map, source)
        return map
    }
}