// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AsqioSupportSDK",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AsqioSupportSDK",
            targets: ["AsqioSupportSDK"]
        ),
    ],
    targets: [
        .target(
            name: "AsqioSupportSDK",
            dependencies: [],
            path: "Sources/AsqioSupportSDK"
        ),
        .testTarget(
            name: "AsqioSupportSDKTests",
            dependencies: ["AsqioSupportSDK"],
            path: "Tests/AsqioSupportSDKTests"
        ),
    ]
)
