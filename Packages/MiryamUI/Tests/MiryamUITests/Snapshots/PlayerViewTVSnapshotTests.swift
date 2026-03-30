#if os(tvOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("PlayerView TV Snapshots")
@MainActor
struct PlayerViewTVSnapshotTests {

    private func makeViewModel() -> PlayerViewModel {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        return PlayerViewModel(player: player, cacheRepository: cacheRepo)
    }

    @Test("PlayerView — TV — Playing — Light Mode")
    func playerPlayingTVLight() {
        let router = Router()
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

        let view = NavigationStack {
            PlayerView(viewModel: viewModel)
        }
        .environment(router)

        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .light
        )
        assertSnapshot(
            of: controller,
            as: .image(on: .tv),
            record: false
        )
    }

    @Test("PlayerView — TV — Playing — Dark Mode")
    func playerPlayingTVDark() {
        let router = Router()
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

        let view = NavigationStack {
            PlayerView(viewModel: viewModel)
        }
        .environment(router)

        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .dark
        )
        assertSnapshot(
            of: controller,
            as: .image(on: .tv),
            record: false
        )
    }

    @Test("PlayerView — TV — Paused — Dark Mode")
    func playerPausedTVDark() {
        let router = Router()
        let viewModel = makeViewModel()
        let song = TestData.makeSong()
        viewModel.currentSong = song
        viewModel.isPlaying = false
        viewModel.playbackState = PlaybackState(
            status: .paused,
            currentSong: song,
            currentTime: 120,
            duration: 354,
            progress: 120.0 / 354.0
        )

        let view = NavigationStack {
            PlayerView(viewModel: viewModel)
        }
        .environment(router)

        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .dark
        )
        assertSnapshot(
            of: controller,
            as: .image(on: .tv),
            record: false
        )
    }
}

#endif // os(tvOS)
