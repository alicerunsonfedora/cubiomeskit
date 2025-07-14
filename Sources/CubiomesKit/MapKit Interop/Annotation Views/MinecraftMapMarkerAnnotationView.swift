//
//  MinecraftMapMarkerAnnotationView.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 14-07-2025.
//

import Foundation
import MapKit
import os

#if canImport(AppKit)
private typealias ImageType = NSImage
#elseif canImport(UIKit)
private typealias ImageType = UIImage
#endif

class MinecraftMapMarkerAnnotationView: MKAnnotationView {
    var configuration: MinecraftMapPlayerMarkerAnnotation?

    private let logger = Logger(
        subsystem: "net.marquiskurt.cubiomes",
        category: "\(MinecraftMapMarkerAnnotationView.self)"
    )

    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented for this class. Are you using this with storyboards?")
    }

    func configure(with configuration: MinecraftMapPlayerMarkerAnnotation) {
        self.configuration = configuration
        canShowCallout = true
        Task {
            await fetchAvatarFromUUID()
        }
    }

    private func fetchAvatarFromUUID() async {
        guard let configuration else {
            logger.error("🧑🏻‍🏭 The player configuration is nil. Using default Steve head.")
            await MainActor.run {
                loadDefaultSteve()
            }
            return
        }
        guard let url = URL(string: "https://mc-heads.net/head/\(configuration.playerUUID.uuidString)/50") else {
            return
        }
        let session = URLSession(configuration: .default)
        let request = URLRequest(url: url)

        do {
            let (data, response) = try await session.data(for: request)
            await MainActor.run {
                let image = ImageType(data: data)
                self.image = image
            }
        } catch {
            logger
                .error(
                    "🧑🏻‍🏭 Failed to get the player's head \(error.localizedDescription). Using default Steve head."
                )
            await MainActor.run {
                loadDefaultSteve()
            }
        }
    }

    private func loadDefaultSteve() {
        let defaultSteve = Bundle.module.image(forResource: "MHF_Steve")
        self.image = defaultSteve
    }
}
