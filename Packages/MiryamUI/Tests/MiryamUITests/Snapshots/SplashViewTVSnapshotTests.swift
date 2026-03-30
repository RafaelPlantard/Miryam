#if os(tvOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI

@Suite("SplashView TV Snapshots")
@MainActor
struct SplashViewTVSnapshotTests {

    @Test("SplashView — TV — Light Mode")
    func splashTVLight() {
        let view = SplashView(onComplete: {})
        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .light
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: .tv, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("SplashView — TV — Dark Mode")
    func splashTVDark() {
        let view = SplashView(onComplete: {})
        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .dark
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: .tv, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }
}

#endif // os(tvOS)
