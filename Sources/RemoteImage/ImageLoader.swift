//
//  ImageLoader.swift
//  RemoteImage
//
//  Created by Paul Calnan on 2/24/22.
//

import Foundation
import Logging
import SwiftUI

public enum ImageLoaderError: Error {
    case invalidResponse
    case httpStatusError(Int)
    case unableToReadImage
}

public actor ImageLoader {

    public static let `default` = ImageLoader(identifier: "default")

    private let log: Logger

    private let session: URLSession

    private var downloadTasks: [URL: Task<ImageType, Error>] = [:]

    public init(identifier: String,
                logLevel: Logger.Level = .warning,
                memoryCacheSize: Int = 10 * (1 << 20),
                fileSystemCacheSize: Int = 200 * (1 << 20)) {

        var log = Logger(label: "[ImageLoader.\(identifier)]")
        log.logLevel = logLevel
        self.log = log

        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cachesURL.appendingPathComponent("ImageCache-\(identifier)")
        log.info("diskCacheURL: \(diskCacheURL)")

        let cache = URLCache(
            memoryCapacity: memoryCacheSize,
            diskCapacity: fileSystemCacheSize,
            directory: diskCacheURL)

        let config = URLSessionConfiguration.default
        config.urlCache = cache

        self.session = URLSession(configuration: config)
    }

    public func loadImage(from url: URL) async throws -> ImageType {
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
        let start = Date().timeIntervalSinceReferenceDate
        let (data, response) = try await data(for: request(for: url))
        let end = Date().timeIntervalSinceReferenceDate

        log.info("\(String(format: "Downloaded %ld byte(s) in %.03f second(s)", data.count, end - start))")

        guard let response = response as? HTTPURLResponse else {
            log.error("response is not an HTTPURLResponse")
            throw ImageLoaderError.invalidResponse
        }

        guard 200...299 ~= response.statusCode else {
            log.error("Invalid status code \(response.statusCode)")
            throw ImageLoaderError.httpStatusError(response.statusCode)
        }

        guard let image = ImageType(data: data) else {
            log.error("Unable to read image -- \(String(describing: ImageType.self)) initializer returned nil")
            throw ImageLoaderError.unableToReadImage
        }

        return image
    }

    private func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if #available(iOS 15.0, *) {
            return try await session.data(for: request)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                session.dataTask(with: request) { data, response, error in
                    guard let data = data, let response = response else {
                        let error = error ?? URLError(.badServerResponse)
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(returning: (data, response))
                }.resume()
            }
        }
    }

    private func request(for url: URL) -> URLRequest {
        URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData)
    }
}
