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
    private let popoverSize = CGSize(width: 414, height: Layout.MoreOptions.sheetHeight)

    private func makeController(
        song: Song,
        interfaceStyle: UIUserInterfaceStyle,
        canvasSize: CGSize?
    ) -> UIViewController {
        let router = Router()
        let view = MoreOptionsView(song: song, onViewAlbum: {})
            .environment(router)

        return SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: interfaceStyle,
            presentation: .centeredPopover(size: popoverSize),
            canvasSize: canvasSize
        )
    }

    @Test("MoreOptionsView — iPad — Default — Light Mode")
    func moreOptionsiPadLight() {
        let song = TestData.makeSong()
        let controller = makeController(
            song: song,
            interfaceStyle: .light,
            canvasSize: SnapshotHelper.padPortraitConfig.size
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: SnapshotHelper.padPortraitConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("MoreOptionsView — iPad — Default — Dark Mode")
    func moreOptionsiPadDark() {
        let song = TestData.makeSong()
        let controller = makeController(
            song: song,
            interfaceStyle: .dark,
            canvasSize: SnapshotHelper.padPortraitConfig.size
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: SnapshotHelper.padPortraitConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("MoreOptionsView — iPad Landscape — Default — Light Mode")
    func moreOptionsiPadLandscapeLight() {
        let song = TestData.makeSong()
        let controller = makeController(
            song: song,
            interfaceStyle: .light,
            canvasSize: SnapshotHelper.padLandscapeConfig.size
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: SnapshotHelper.padLandscapeConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("MoreOptionsView — iPad Landscape — Default — Dark Mode")
    func moreOptionsiPadLandscapeDark() {
        let song = TestData.makeSong()
        let controller = makeController(
            song: song,
            interfaceStyle: .dark,
            canvasSize: SnapshotHelper.padLandscapeConfig.size
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: SnapshotHelper.padLandscapeConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }
}

#endif // os(iOS)
