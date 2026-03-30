#if os(iOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI

@Suite("SplashView iPad Snapshots")
@MainActor
struct SplashViewiPadSnapshotTests {

    @Test("SplashView — iPad — Light Mode")
    func splashiPadLight() {
        let view = SplashView(onComplete: {})
        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .light
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: .iPadPro11(.portrait), precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("SplashView — iPad — Dark Mode")
    func splashiPadDark() {
        let view = SplashView(onComplete: {})
        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .dark
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: .iPadPro11(.portrait), precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }
}

#endif // os(iOS)
