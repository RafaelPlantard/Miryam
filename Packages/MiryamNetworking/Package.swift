// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MiryamNetworking",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "MiryamNetworking", targets: ["MiryamNetworking"])
    ],
    dependencies: [
        .package(path: "../MiryamCore")
    ],
    targets: [
        .target(
            name: "MiryamNetworking",
            dependencies: ["MiryamCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "MiryamNetworkingTests",
            dependencies: ["MiryamNetworking", "MiryamCore"]
        )
    ]
)
