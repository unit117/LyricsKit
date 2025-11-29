// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "LyricsKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "LyricsKit",
            targets: ["LyricsCore", "LyricsService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ddddxxx/Regex", from: "1.0.1"),
        .package(url: "https://github.com/ddddxxx/SwiftCF", .upToNextMinor(from: "0.2.0")),
        .package(url: "https://github.com/1024jp/GzipSwift", from: "6.0.0"),
    ],
    targets: [
        .target(
            name: "LyricsCore",
            dependencies: ["Regex", "SwiftCF"]),
        .target(
            name: "LyricsService",
            dependencies: [
                "LyricsCore",
                "Regex",
                .product(name: "Gzip", package: "GzipSwift")
            ]),
        .testTarget(
            name: "LyricsKitTests",
            dependencies: ["LyricsCore", "LyricsService"],
            resources: [.copy("Resources")]),
    ]
)
