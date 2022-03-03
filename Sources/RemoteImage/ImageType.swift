//
//  ImageType.swift
//  RemoteImage
//
//  Created by Paul Calnan on 2/25/22.
//

/*
 Typealias an `ImageType` to either `UIImage` or `NSImage` depending on our platform.
 */

import SwiftUI

#if os(iOS)

import UIKit
public typealias ImageType = UIImage

extension ImageType {
    var swiftUIImage: Image {
        Image(uiImage: self)
    }
}

#elseif os(macOS)

import AppKit
public typealias ImageType = NSImage

extension ImageType {
    var swiftUIImage: Image {
        Image(nsImage: self)
    }
}

#endif
