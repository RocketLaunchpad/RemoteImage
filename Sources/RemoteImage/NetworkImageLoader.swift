//
//  NetworkImageLoader.swift
//  RemoteImage
//
//  Created by Paul Calnan on 2/24/22.
//

import Foundation

actor NetworkImageLoader {

    private let session: URLSession

    private var downloadTasks: [URL: Task<LoadedImage, Error>] = [:]

    init(session: URLSession = .shared) {
        self.session = session
    }

    func metadata(for url: URL) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        let (data, response) = try await session.data(for: request)
        
    }

    func loadImage(from url: URL) async throws -> LoadedImage {
        if let task = downloadTasks[url] {
            return try await task.value
        }

        let task = Task {
            try await downloadImage(from: url)
        }
        downloadTasks[url] = task

        defer {
            downloadTasks[url] = nil
        }
        return try await task.value
    }

    private func downloadImage(from url: URL) async throws -> LoadedImage {
        let (data, response) = try await session.data(for: URLRequest(url: url))
        guard let response = response as? HTTPURLResponse else {
            throw ImageLoaderError.invalidResponse
        }

        guard 200...299 ~= response.statusCode else {
            throw ImageLoaderError.httpStatusError(response.statusCode)
        }

        return try LoadedImage(data: data)
    }
}
