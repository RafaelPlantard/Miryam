#if os(iOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("AlbumView Snapshots")
@MainActor
struct AlbumViewSnapshotTests {

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

    // MARK: Loaded State

    @Test("AlbumView — Loaded — Light Mode")
    func albumLoadedLight() {
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
            as: .image(on: SnapshotHelper.phoneConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("AlbumView — Loaded — Dark Mode")
    func albumLoadedDark() {
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
            as: .image(on: SnapshotHelper.phoneConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    // MARK: Loading State

    @Test("AlbumView — Loading — Light Mode")
    func albumLoadingLight() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let songRepo = MockSongRepository()
        let viewModel = AlbumViewModel(album: TestData.makeAlbum(), songRepository: songRepo)
        viewModel.isLoading = true
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
            as: .image(on: SnapshotHelper.phoneConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("AlbumView — Loading — Dark Mode")
    func albumLoadingDark() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let songRepo = MockSongRepository()
        let viewModel = AlbumViewModel(album: TestData.makeAlbum(), songRepository: songRepo)
        viewModel.isLoading = true
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
            as: .image(on: SnapshotHelper.phoneConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    // MARK: Error State

    @Test("AlbumView — Error — Light Mode")
    func albumErrorLight() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let songRepo = MockSongRepository()
        let viewModel = AlbumViewModel(album: TestData.makeAlbum(), songRepository: songRepo)
        viewModel.error = .networkError("Connection failed")
        viewModel.isLoading = false
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
            as: .image(on: SnapshotHelper.phoneConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("AlbumView — Error — Dark Mode")
    func albumErrorDark() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let songRepo = MockSongRepository()
        let viewModel = AlbumViewModel(album: TestData.makeAlbum(), songRepository: songRepo)
        viewModel.error = .networkError("Connection failed")
        viewModel.isLoading = false
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
            as: .image(on: SnapshotHelper.phoneConfig, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }
}

#endif // os(iOS)
