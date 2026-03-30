// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MiryamPersistence",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "MiryamPersistence", targets: ["MiryamPersistence"])
    ],
    dependencies: [
        .package(path: "../MiryamCore")
    ],
    targets: [
        .target(
            name: "MiryamPersistence",
            dependencies: ["MiryamCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "MiryamPersistenceTests",
            dependencies: ["MiryamPersistence", "MiryamCore"]
        )
    ]
)
