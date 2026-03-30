#if os(iOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("MoreOptionsView iPad Snapshots")
@MainActor
struct MoreOptionsViewiPadSnapshotTests {

    @Test("MoreOptionsView — iPad — Default — Light Mode")
    func moreOptionsiPadLight() {
        let router = Router()
        let song = TestData.makeSong()
        let view = NavigationStack {
            MoreOptionsView(song: song, onViewAlbum: {})
        }
        .environment(router)

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

    @Test("MoreOptionsView — iPad — Default — Dark Mode")
    func moreOptionsiPadDark() {
        let router = Router()
        let song = TestData.makeSong()
        let view = NavigationStack {
            MoreOptionsView(song: song, onViewAlbum: {})
        }
        .environment(router)

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
