//
//  NetworkImageLoader.swift
//  RemoteImage
//
//  Created by Paul Calnan on 2/24/22.
//

import Foundation

actor NetworkImageLoader {

    private let session: URLSession

    private var downloadTasks: [URL: Task<ImageType, Error>] = [:]

    init(session: URLSession = .shared) {
        self.session = session
    }

    func loadImage(from url: URL) async throws -> ImageType {
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

    private func downloadImage(from url: URL) async throws -> ImageType {
        let (data, response) = try await session.data(for: URLRequest(url: url))
        guard let response = response as? HTTPURLResponse else {
            throw ImageLoaderError.invalidResponse
        }

        guard 200...299 ~= response.statusCode else {
            throw ImageLoaderError.httpStatusError(response.statusCode)
        }

        guard let image = ImageType(data: data) else {
            throw ImageLoaderError.unableToLoadImage
        }

        return image
    }
}
