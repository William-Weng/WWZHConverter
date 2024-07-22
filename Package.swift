// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWZHConverter",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "WWZHConverter", targets: ["WWZHConverter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/William-Weng/WWNetworking.git", from: "1.6.2"),
    ],
    targets: [
        .target(name: "WWZHConverter", dependencies: ["WWNetworking"], resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
