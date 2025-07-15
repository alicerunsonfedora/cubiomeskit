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
                loadDefaultSteveIfAvailable()
            }
            return
        }
        guard let url = URL(string: "https://mc-heads.net/head/\(configuration.playerUUID.uuidString)/30") else {
            return
        }
        let session = URLSession(configuration: .default)
        let request = URLRequest(url: url)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResp = response as? HTTPURLResponse, (200..<300).contains(httpResp.statusCode) else {
                logger.error("🧑🏻‍🏭 The response returned badly. Using default Steve head.")
                await MainActor.run {
                    loadDefaultSteveIfAvailable()
                }
                return
            }
            
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
                loadDefaultSteveIfAvailable()
            }
        }
    }

    private func loadDefaultSteveIfAvailable() {
        #if canImport(UIKit)
        let image = UIImage(named: "MHF_Steve", in: .module, compatibleWith: nil)
        #else
        let bundle = Bundle.module
        let image = bundle.image(forResource: "MHF_Steve")
        #endif

        if image == nil {
            logger.error("🧑🏻‍🏭 Steve is missing. Is the file included in the xcassets?")
        }
        
        self.image = image
    }
}
