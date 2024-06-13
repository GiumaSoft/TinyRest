// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TinyRest",
    platforms: [
      .iOS(.v15), .macOS(.v13)
    ],
    products: [
        .library(
            name: "TinyRest",
            targets: ["TinyRest"]
        )
    ],
    targets: [
        .target(
            name: "TinyRest"
        )
    ]
)
