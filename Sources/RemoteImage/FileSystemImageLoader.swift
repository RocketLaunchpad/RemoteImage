//
//  FileSystemImageLoader.swift
//  RemoteImage
//
//  Created by Paul Calnan on 2/24/22.
//

import CryptoKit
import Foundation

actor FileSystemImageLoader {
    let networkLoader: NetworkImageLoader

    private let cacheDirectory: URL

    init(networkLoader: NetworkImageLoader) {
        self.networkLoader = networkLoader

        do {
            cacheDirectory = try FileManager.default
                .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("ImageCache")
        }
        catch {
            fatalError("Could not determine cache directory")
        }
    }

    private func fileSystemURL(for remoteURL: URL) -> URL {
        // Hex-string representation of the SHA256 hash of remoteURL
        let hash = SHA256
            .hash(data: remoteURL.dataRepresentation)
            .map {
                String(format: "%02hhx", $0)
            }
            .joined()

        return cacheDirectory.appendingPathComponent(hash)
    }

    func loadImage(from remoteURL: URL) async throws -> ImageType {
        let fileSystemURL = self.fileSystemURL(for: remoteURL)

        if let cached = loadLocalFile(at: fileSystemURL) {
            return cached
        }

        let loaded = try await networkLoader.loadImage(from: remoteURL)
        try write(image: loaded, toLocalFileAt: fileSystemURL)
        return loaded.image
    }

    private func loadLocalFile(at url: URL) -> ImageType? {
        ImageType(contentsOf: url)
    }

    private func write(image: LoadedImage, toLocalFileAt url: URL) throws {
        // TODO: Do we really want to throw here?
        try image.data.write(to: url)
    }
}
