#if os(iOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("PlayerView iPad Snapshots")
@MainActor
struct PlayerViewiPadSnapshotTests {

    private func makeViewModel() -> PlayerViewModel {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        return PlayerViewModel(player: player, cacheRepository: cacheRepo)
    }

    @Test("PlayerView — iPad — Playing — Light Mode")
    func playerPlayingiPadLight() {
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
            as: .image(on: .iPadPro11(.portrait), precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("PlayerView — iPad — Playing — Dark Mode")
    func playerPlayingiPadDark() {
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
            as: .image(on: .iPadPro11(.portrait), precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("PlayerView — iPad Landscape — Playing — Dark Mode")
    func playerPlayingiPadLandscapeDark() {
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
            as: .image(on: .iPadPro11(.landscape), precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }
}

#endif // os(iOS)
