#if os(iOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("MoreOptionsView Snapshots")
@MainActor
struct MoreOptionsViewSnapshotTests {

    // MARK: Default State

    @Test("MoreOptionsView — Default — Light Mode")
    func moreOptionsLight() {
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("MoreOptionsView — Default — Dark Mode")
    func moreOptionsDark() {
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    // MARK: With Long Song Name

    @Test("MoreOptionsView — Long Song Name — Light Mode")
    func moreOptionsLongNameLight() {
        let router = Router()
        let song = TestData.makeSong(
            name: "A Very Long Song Title That Should Truncate Properly in the UI",
            artistName: "An Artist With a Really Long Name That Exceeds Expectations"
        )
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("MoreOptionsView — Long Song Name — Dark Mode")
    func moreOptionsLongNameDark() {
        let router = Router()
        let song = TestData.makeSong(
            name: "A Very Long Song Title That Should Truncate Properly in the UI",
            artistName: "An Artist With a Really Long Name That Exceeds Expectations"
        )
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }
}

#endif // os(iOS)
