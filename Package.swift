// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoadingPublisher",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "LoadingPublisher", targets: ["LoadingPublisher"])
    ],
    dependencies: [],
    targets: [
        .target(name: "LoadingPublisher", dependencies: []),
        .testTarget(name: "LoadingPublisherTests", dependencies: ["LoadingPublisher"])
    ],
    swiftLanguageModes: [.v6]
)
