//
//  RemoteImageLoader.swift
//  RemoteImage
//
//  Created by Paul Calnan on 2/25/22.
//

import Foundation

public class RemoteImageLoader {

    private let inMemoryCache: InMemoryCache

    init(session: URLSession = .shared) {
        let networkLoader = NetworkImageLoader(session: session)
        inMemoryCache = InMemoryCache(networkLoader: networkLoader)
    }

    func loadImage(from url: URL) async throws -> ImageType {
        try await inMemoryCache.loadImage(from: url)
    }
}
