//
//  Logging.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 03-10-2025.
//

#if !canImport(OSLog)
/// A shim logger used to maintain compatibility on Linux and Windows.
struct ShimLogger {
    var subsystem: String
    var category: String

    func debug(_ msg: String) {
        print("[DEBUG]: \(msg)")
    }

    func warning(_ msg: String) {
        print("[WARN]: \(msg)")
    }

    func error(_ msg: String) {
        print("[ERR]: \(msg)")
    }
}

typealias Logger = ShimLogger
#endif