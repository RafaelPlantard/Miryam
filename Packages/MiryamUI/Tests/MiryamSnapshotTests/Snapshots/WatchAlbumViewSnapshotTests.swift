#if os(iOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("WatchAlbumView Snapshots")
@MainActor
struct WatchAlbumViewSnapshotTests {

    /// Apple Watch Series 10 (46mm) screen size in points.
    private static let watchSize = CGSize(width: 198, height: 242)

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

    @Test("WatchAlbumView — Loaded — Light Mode")
    func watchAlbumLoadedLight() {
        let viewModel = makeViewModel()
        let view = NavigationStack {
            WatchAlbumView(viewModel: viewModel, onPlaySong: { _ in })
        }

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

    @Test("WatchAlbumView — Loaded — Dark Mode")
    func watchAlbumLoadedDark() {
        let viewModel = makeViewModel()
        let view = NavigationStack {
            WatchAlbumView(viewModel: viewModel, onPlaySong: { _ in })
        }

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
