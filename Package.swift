// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AsqioSDK",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AsqioSDK",
            targets: ["AsqioSDK"]
        ),
    ],
    targets: [
        .target(
            name: "AsqioSDK",
            dependencies: [],
            path: "Sources/AsqioSDK"
        ),
        .testTarget(
            name: "AsqioSDKTests",
            dependencies: ["AsqioSDK"],
            path: "Tests/AsqioSDKTests"
        ),
    ]
)
