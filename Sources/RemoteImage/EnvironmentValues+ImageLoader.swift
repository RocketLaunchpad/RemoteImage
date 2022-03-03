//
//  EnvironmentValues+ImageLoader.swift
//  RemoteImage
//
//  Created by Paul Calnan on 3/3/22.
//

import SwiftUI

private struct ImageLoaderEnvironmentKey: EnvironmentKey {
    static let defaultValue: ImageLoader = .default
}

public extension EnvironmentValues {
    var imageLoader: ImageLoader {
        get {
            self[ImageLoaderEnvironmentKey.self]
        }

        set {
            self[ImageLoaderEnvironmentKey.self] = newValue
        }
    }
}
