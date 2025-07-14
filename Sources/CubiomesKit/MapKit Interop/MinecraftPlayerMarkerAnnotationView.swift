//
//  MinecraftPlayerMarkerAnnotationView.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 14-07-2025.
//

import Foundation
import MapKit

class MinecraftPlayerMarkerAnnotationView: MKMarkerAnnotationView {
    var configuration: MinecraftMapPlayerMarkerAnnotation?

    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        if let player = annotation as? MinecraftMapPlayerMarkerAnnotation {
            self.configure(withConfiguration: player)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure(withConfiguration configuration: MinecraftMapPlayerMarkerAnnotation) {
        self.configuration = configuration
        self.tintColor = .blue
        fetchAvatar { data in
            if let data {
                DispatchQueue.main.async {
                    #if canImport(AppKit)
                        self.glyphImage = NSImage(data: data)
                    #elseif canImport(UIKit)
                        self.glyphImage = UIImage(data: data)
                    #endif
                }
            }
        }
    }

    private func fetchAvatar(completion: @escaping @Sendable (Data?) -> Void) {
        guard let configuration else { return }
        guard let url = URL(string: "https://mc-heads.net/avatar/\(configuration.playerUUID.uuidString)") else {
            return
        }
        let session = URLSession(configuration: .default)
        let request = URLRequest(url: url)
        session.dataTask(with: request) { [completion] data, response, error in
            guard error == nil else { return }
            completion(data)
        }
    }
}
