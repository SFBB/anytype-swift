// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SharedContentManager",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "SharedContentManager",
            type: .dynamic,
            targets: ["SharedContentManager"]),
    ],
    dependencies: [
        .package(path: "../AnytypeCore")
    ],
    targets: [
        .target(
            name: "SharedContentManager",
            dependencies: ["AnytypeCore"],
            path: "Sources"
        )
    ]
)
