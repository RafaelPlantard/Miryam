#if os(iOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("WatchNowPlayingView Snapshots")
@MainActor
struct WatchNowPlayingViewSnapshotTests {

    /// Apple Watch Series 10 (46mm) screen size in points.
    private static let watchSize = CGSize(width: 198, height: 242)

    private func makeViewModel() -> PlayerViewModel {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        return PlayerViewModel(player: player, cacheRepository: cacheRepo)
    }

    // MARK: Playing State

    @Test("WatchNowPlayingView — Playing — Light Mode")
    func watchPlayingLight() {
        let viewModel = makeViewModel()
        let song = TestData.makeSong()
        viewModel.currentSong = song
        viewModel.isPlaying = true
        viewModel.playbackState = PlaybackState(
            status: .playing,
            currentSong: song,
            currentTime: 90,
            duration: 354,
            progress: 90.0 / 354.0
        )

        let view = WatchNowPlayingView(viewModel: viewModel)
        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .light
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(precision: 0.995, perceptualPrecision: 0.98, size: Self.watchSize),
            record: false
        )
    }

    @Test("WatchNowPlayingView — Playing — Dark Mode")
    func watchPlayingDark() {
        let viewModel = makeViewModel()
        let song = TestData.makeSong()
        viewModel.currentSong = song
        viewModel.isPlaying = true
        viewModel.playbackState = PlaybackState(
            status: .playing,
            currentSong: song,
            currentTime: 90,
            duration: 354,
            progress: 90.0 / 354.0
        )

        let view = WatchNowPlayingView(viewModel: viewModel)
        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .dark
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(precision: 0.995, perceptualPrecision: 0.98, size: Self.watchSize),
            record: false
        )
    }

    // MARK: Idle State

    @Test("WatchNowPlayingView — Idle — Light Mode")
    func watchIdleLight() {
        let viewModel = makeViewModel()

        let view = WatchNowPlayingView(viewModel: viewModel)
        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .light
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(precision: 0.995, perceptualPrecision: 0.98, size: Self.watchSize),
            record: false
        )
    }

    @Test("WatchNowPlayingView — Idle — Dark Mode")
    func watchIdleDark() {
        let viewModel = makeViewModel()

        let view = WatchNowPlayingView(viewModel: viewModel)
        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .dark
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(precision: 0.995, perceptualPrecision: 0.98, size: Self.watchSize),
            record: false
        )
    }
}

#endif // os(iOS)
