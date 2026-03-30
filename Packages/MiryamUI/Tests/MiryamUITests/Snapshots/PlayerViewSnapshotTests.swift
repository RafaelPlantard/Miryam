#if os(iOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("PlayerView Snapshots")
@MainActor
struct PlayerViewSnapshotTests {

    private func makeViewModel() -> PlayerViewModel {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        return PlayerViewModel(player: player, cacheRepository: cacheRepo)
    }

    // MARK: Playing State

    @Test("PlayerView — Playing — Light Mode")
    func playerPlayingLight() {
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
            as: .image(on: .iPhone13Pro),
            record: true
        )
    }

    @Test("PlayerView — Playing — Dark Mode")
    func playerPlayingDark() {
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
            as: .image(on: .iPhone13Pro),
            record: true
        )
    }

    // MARK: Paused State

    @Test("PlayerView — Paused — Light Mode")
    func playerPausedLight() {
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
            interfaceStyle: .light
        )
        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
            record: true
        )
    }

    @Test("PlayerView — Paused — Dark Mode")
    func playerPausedDark() {
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
            as: .image(on: .iPhone13Pro),
            record: true
        )
    }

    // MARK: Idle State (No Song)

    @Test("PlayerView — Idle (No Song) — Light Mode")
    func playerIdleLight() {
        let router = Router()
        let viewModel = makeViewModel()

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
            as: .image(on: .iPhone13Pro),
            record: true
        )
    }

    @Test("PlayerView — Idle (No Song) — Dark Mode")
    func playerIdleDark() {
        let router = Router()
        let viewModel = makeViewModel()

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
            as: .image(on: .iPhone13Pro),
            record: true
        )
    }
}

#endif // os(iOS)
