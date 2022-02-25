//
//  ImageLoader.swift
//  RemoteImage
//
//  Created by Paul Calnan on 2/24/22.
//

#if os(iOS)
import UIKit
public typealias ImageType = UIImage
#elseif os(macOS)
import AppKit
public typealias ImageType = NSImage
#endif

public enum ImageLoaderError: Error {
    case invalidResponse
    case httpStatusError(Int)
    case unableToLoadImage
    case notFound
}

struct LoadedImage {
    var image: ImageType
    var data: Data

    init(data: Data) throws {
        guard let image = ImageType(data: data) else {
            throw ImageLoaderError.unableToLoadImage
        }
        self.image = image
        self.data = data
    }
}
