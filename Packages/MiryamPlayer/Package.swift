// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MiryamPlayer",
    platforms: [
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "MiryamPlayer", targets: ["MiryamPlayer"])
    ],
    dependencies: [
        .package(path: "../MiryamCore")
    ],
    targets: [
        .target(
            name: "MiryamPlayer",
            dependencies: ["MiryamCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "MiryamPlayerTests",
            dependencies: ["MiryamPlayer", "MiryamCore"]
        )
    ]
)
