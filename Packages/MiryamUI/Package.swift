// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MiryamUI",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "MiryamUI", targets: ["MiryamUI"])
    ],
    dependencies: [
        .package(path: "../MiryamCore"),
        .package(path: "../MiryamFeatures")
    ],
    targets: [
        .target(
            name: "MiryamUI",
            dependencies: ["MiryamCore", "MiryamFeatures"],
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "MiryamUITests",
            dependencies: ["MiryamUI", "MiryamFeatures", "MiryamCore"]
        )
    ]
)
