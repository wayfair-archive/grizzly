// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Grizzly",
    products: [
        .executable(
            name: "grizzly",
            targets: ["Grizzly"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/wayfair/swift-parsers", .branch("master")
        )
    ],
    targets: [
        .target(
            name: "GrizzlyCore",
            dependencies: ["Parsers"]
        ),
        .testTarget(
            name: "GrizzlyTests",
            dependencies: ["GrizzlyCore"]
        ),
        .target(
            name: "Grizzly",
            dependencies: ["GrizzlyCore"]
        )
    ]
)
