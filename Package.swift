// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
        name: "Tea",
        platforms: [.macOS(.v11)],
        products: [
            .library(
                    name: "Tea",
                    targets: ["Tea"]),
        ],
        dependencies: [
            .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "6.1.0"),
            .package(url: "https://github.com/bow-swift/bow.git", from: "0.8.0"),
            .package(url: "https://github.com/bendiksolheim/Slowbox", from: "0.5.0"),
            .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0"))
        ],
        targets: [
            .target(
                    name: "Tea",
                    dependencies: [
                        "ReactiveSwift",
                        "Slowbox",
                        .product(name: "BowEffects", package: "bow"),
                        .product(name: "Swifter", package: "swifter")
                    ]),
            .testTarget(
                    name: "TeaTests",
                    dependencies: ["Tea"]),
        ]
)
