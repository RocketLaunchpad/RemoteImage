//
//  InMemoryCache.swift
//  RemoteImage
//
//  Created by Paul Calnan on 2/25/22.
//

import Foundation

actor InMemoryCache {
    let fileSystemLoader: FileSystemImageLoader

    private let cache = NSCache<NSURL, ImageType>()

    init(fileSystemLoader: FileSystemImageLoader) {
        self.fileSystemLoader = fileSystemLoader
    }

    func loadImage(from url: URL) async throws -> ImageType {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }

        let loaded = try await fileSystemLoader.loadImage(from: url)
        cache.setObject(loaded, forKey: url as NSURL)
        return loaded
    }
}
