#if os(tvOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("SongsView TV Snapshots")
@MainActor
struct SongsViewTVSnapshotTests {

    private func makeViewModel() -> SongsViewModel {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        return SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)
    }

    @Test("SongsView — TV — Empty State — Light Mode")
    func songsEmptyTVLight() {
        let router = Router()
        let viewModel = makeViewModel()
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
        }
        .environment(router)

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

    @Test("SongsView — TV — Empty State — Dark Mode")
    func songsEmptyTVDark() {
        let router = Router()
        let viewModel = makeViewModel()
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
        }
        .environment(router)

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

    @Test("SongsView — TV — With Results — Light Mode")
    func songsWithResultsTVLight() {
        let router = Router()
        let viewModel = makeViewModel()
        viewModel.songs = TestData.sampleSongs
        viewModel.searchQuery = "Queen"
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
        }
        .environment(router)

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

    @Test("SongsView — TV — With Results — Dark Mode")
    func songsWithResultsTVDark() {
        let router = Router()
        let viewModel = makeViewModel()
        viewModel.songs = TestData.sampleSongs
        viewModel.searchQuery = "Queen"
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
        }
        .environment(router)

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
