// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "AnytypeCore",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "AnytypeCore",
            type: .dynamic,
            targets: ["AnytypeCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.21.0"),
        .package(path: "../Logger")
    ],
    targets: [
        .target(
            name: "AnytypeCore",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "Logger"
            ],
            path: "AnytypeCore"
        )
    ]
)
