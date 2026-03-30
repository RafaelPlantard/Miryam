// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MiryamCore",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "MiryamCore", targets: ["MiryamCore"])
    ],
    targets: [
        .target(
            name: "MiryamCore",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "MiryamCoreTests",
            dependencies: ["MiryamCore"]
        )
    ]
)
