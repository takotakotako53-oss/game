// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Game",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Game",
            targets: ["Game"]),
    ],
    dependencies: [
        // 必要に応じて依存関係を追加
    ],
    targets: [
        .target(
            name: "Game",
            dependencies: []),
        .testTarget(
            name: "GameTests",
            dependencies: ["Game"]),
    ]
)

