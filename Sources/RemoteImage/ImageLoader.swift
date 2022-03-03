//
//  ImageLoader.swift
//  RemoteImage
//
//  Copyright (c) 2021 Rocket Insights, Inc.
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
