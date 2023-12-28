// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AnytypeCore",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "AnytypeCore",
            type: .dynamic,
            targets: ["AnytypeCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.21.0"),
        .package(path: "../Logger"),
        // Waiting issue - https://github.com/krzysztofzablocki/Sourcery/issues/1090
        .package(url: "https://github.com/anyproto/SourceryGenPlugin", revision: "1.9.4")
    ],
    targets: [
        .target(
            name: "AnytypeCore",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "Logger"
            ],
            path: "AnytypeCore",
            plugins: [
                .plugin(name: "SourceryGenPlugin", package: "SourceryGenPlugin")
            ]
        )
    ]
)
