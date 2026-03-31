#if os(iOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("AlbumView iPad Snapshots")
@MainActor
struct AlbumViewiPadSnapshotTests {

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

    @Test("AlbumView — iPad — Loaded — Light Mode")
    func albumLoadediPadLight() {
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
            as: .image(on: .iPadPro11(.portrait), precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("AlbumView — iPad — Loaded — Dark Mode")
    func albumLoadediPadDark() {
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
            as: .image(on: .iPadPro11(.portrait), precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("AlbumView — iPad Landscape — Loaded — Light Mode")
    func albumLoadediPadLandscapeLight() {
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
            as: .image(on: .iPadPro11(.landscape), precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("AlbumView — iPad Landscape — Loaded — Dark Mode")
    func albumLoadediPadLandscapeDark() {
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
            as: .image(on: .iPadPro11(.landscape), precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }
}

#endif // os(iOS)
