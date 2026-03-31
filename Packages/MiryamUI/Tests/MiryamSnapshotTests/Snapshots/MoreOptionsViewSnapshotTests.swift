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
    private func makeController(
        song: Song,
        interfaceStyle: UIUserInterfaceStyle
    ) -> UIViewController {
        let router = Router()
        let view = MoreOptionsView(song: song, onViewAlbum: {})
            .environment(router)

        return SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: interfaceStyle,
            presentation: .bottomSheet(height: Layout.MoreOptions.sheetHeight),
            canvasSize: SnapshotHelper.phoneConfig.size
        )
    }

    // MARK: Default State

    @Test("MoreOptionsView — Default — Light Mode")
    func moreOptionsLight() {
        let song = TestData.makeSong()
        let controller = makeController(song: song, interfaceStyle: .light)
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: SnapshotHelper.phoneConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("MoreOptionsView — Default — Dark Mode")
    func moreOptionsDark() {
        let song = TestData.makeSong()
        let controller = makeController(song: song, interfaceStyle: .dark)
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: SnapshotHelper.phoneConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    // MARK: With Long Song Name

    @Test("MoreOptionsView — Long Song Name — Light Mode")
    func moreOptionsLongNameLight() {
        let song = TestData.makeSong(
            name: "A Very Long Song Title That Should Truncate Properly in the UI",
            artistName: "An Artist With a Really Long Name That Exceeds Expectations"
        )
        let controller = makeController(song: song, interfaceStyle: .light)
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: SnapshotHelper.phoneConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("MoreOptionsView — Long Song Name — Dark Mode")
    func moreOptionsLongNameDark() {
        let song = TestData.makeSong(
            name: "A Very Long Song Title That Should Truncate Properly in the UI",
            artistName: "An Artist With a Really Long Name That Exceeds Expectations"
        )
        let controller = makeController(song: song, interfaceStyle: .dark)
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: SnapshotHelper.phoneConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }
}

#endif // os(iOS)
