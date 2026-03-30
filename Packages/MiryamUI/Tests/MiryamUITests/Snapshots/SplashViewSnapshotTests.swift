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
        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
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
        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
            record: false
        )
    }
}

#endif // os(iOS)
