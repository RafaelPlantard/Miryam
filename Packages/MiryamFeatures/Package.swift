// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MiryamFeatures",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "MiryamFeatures", targets: ["MiryamFeatures"])
    ],
    dependencies: [
        .package(path: "../MiryamCore"),
        .package(path: "../MiryamNetworking"),
        .package(path: "../MiryamPersistence"),
        .package(path: "../MiryamPlayer")
    ],
    targets: [
        .target(
            name: "MiryamFeatures",
            dependencies: [
                "MiryamCore",
                "MiryamNetworking",
                "MiryamPersistence",
                "MiryamPlayer"
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "MiryamFeaturesTests",
            dependencies: ["MiryamFeatures", "MiryamCore"]
        )
    ]
)
