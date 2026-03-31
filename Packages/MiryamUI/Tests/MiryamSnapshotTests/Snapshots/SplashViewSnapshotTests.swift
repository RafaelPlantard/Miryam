#if os(iOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI

@Suite("SplashView Snapshots")
@MainActor
struct SplashViewSnapshotTests {

    @Test("SplashView — Light Mode")
    func splashLightMode() {
        let view = SplashView(onComplete: {})
        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .light
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: SnapshotHelper.phoneConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("SplashView — Dark Mode")
    func splashDarkMode() {
        let view = SplashView(onComplete: {})
        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .dark
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: SnapshotHelper.phoneConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }
}

#endif // os(iOS)
