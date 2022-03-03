// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "RemoteImage",
    platforms: [
        .iOS(.v13),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "RemoteImage",
            targets: ["RemoteImage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "RemoteImage",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ]),
        .testTarget(
            name: "RemoteImageTests",
            dependencies: [
                "RemoteImage",
                .product(name: "Logging", package: "swift-log"),
            ]),
    ]
)
