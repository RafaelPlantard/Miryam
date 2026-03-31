#if os(tvOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("AlbumView TV Snapshots")
@MainActor
struct AlbumViewTVSnapshotTests {

    private func makeViewModel(
        album: Album = TestData.makeAlbum(),
        songs: [Song] = TestData.sampleSongs
    ) -> AlbumViewModel {
        let songRepo = MockSongRepository()
        let viewModel = AlbumViewModel(album: album, songRepository: songRepo)
        viewModel.songs = songs
        viewModel.isLoading = false
        return viewModel
    }

    @Test("AlbumView — TV — Loaded — Light Mode")
    func albumLoadedTVLight() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let viewModel = makeViewModel()
        let view = NavigationStack {
            AlbumView(viewModel: viewModel, onPlaySong: { _ in })
        }
        .environment(router)
        .environment(playerViewModel)

        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .light
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: .tv, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("AlbumView — TV — Loaded — Dark Mode")
    func albumLoadedTVDark() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let viewModel = makeViewModel()
        let view = NavigationStack {
            AlbumView(viewModel: viewModel, onPlaySong: { _ in })
        }
        .environment(router)
        .environment(playerViewModel)

        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .dark
        )
        SnapshotHelper.assertSnapshot(
            of: controller,
            as: .image(on: .tv, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }
}

#endif // os(tvOS)
