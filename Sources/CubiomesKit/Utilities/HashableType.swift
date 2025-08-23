//
//  HashableType.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 23-08-2025.
//

import Foundation

struct HashableType<T>: Hashable {
    let base: T.Type

    init(_ base: T.Type) {
        self.base = base
    }

    static func == (lhs: HashableType, rhs: HashableType) -> Bool {
        lhs.base == rhs.base
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(base))
    }
}

extension Dictionary {
    subscript<T>(key: T.Type) -> Value? where Key == HashableType<T> {
        get { return self[HashableType(key)] }
        set { self[HashableType(key)] = newValue }
    }
}
