#if os(tvOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("MoreOptionsView TV Snapshots")
@MainActor
struct MoreOptionsViewTVSnapshotTests {

    @Test("MoreOptionsView — TV — Light Mode")
    func moreOptionsTVLight() {
        let router = Router()
        let song = TestData.makeSong()
        let view = MoreOptionsView(song: song, onViewAlbum: {})
            .environment(router)

        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .light
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: SnapshotHelper.tvConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("MoreOptionsView — TV — Dark Mode")
    func moreOptionsTVDark() {
        let router = Router()
        let song = TestData.makeSong()
        let view = MoreOptionsView(song: song, onViewAlbum: {})
            .environment(router)

        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .dark
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: SnapshotHelper.tvConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }
}

#endif // os(tvOS)
