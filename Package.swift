// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tea",
    platforms: [ .macOS(.v11) ],
    products: [
        .library(
            name: "Tea",
            targets: ["Tea"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "6.1.0"),
        .package(url: "https://github.com/bendiksolheim/Slowbox", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "Tea",
            dependencies: ["ReactiveSwift", "Slowbox"]),
        .testTarget(
            name: "TeaTests",
            dependencies: ["Tea"]),
    ]
)
