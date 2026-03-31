#if os(iOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("SongsView iPad Snapshots")
@MainActor
struct SongsViewiPadSnapshotTests {

    private func makeViewModel() -> SongsViewModel {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        return SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)
    }

    @Test("SongsView — iPad — Empty State — Light Mode")
    func songsEmptyiPadLight() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let viewModel = makeViewModel()
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
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

    @Test("SongsView — iPad — Empty State — Dark Mode")
    func songsEmptyiPadDark() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let viewModel = makeViewModel()
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
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

    @Test("SongsView — iPad — With Results — Light Mode")
    func songsWithResultsiPadLight() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let viewModel = makeViewModel()
        viewModel.songs = TestData.sampleSongs
        viewModel.searchQuery = "Queen"
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
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

    @Test("SongsView — iPad — With Results — Dark Mode")
    func songsWithResultsiPadDark() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let viewModel = makeViewModel()
        viewModel.songs = TestData.sampleSongs
        viewModel.searchQuery = "Queen"
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
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

    @Test("SongsView — iPad Landscape — With Results — Dark Mode")
    func songsWithResultsiPadLandscapeDark() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let viewModel = makeViewModel()
        viewModel.songs = TestData.sampleSongs
        viewModel.searchQuery = "Queen"
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
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

    @Test("SongsView — iPad Landscape — With Results — Light Mode")
    func songsWithResultsiPadLandscapeLight() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let viewModel = makeViewModel()
        viewModel.songs = TestData.sampleSongs
        viewModel.searchQuery = "Queen"
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
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

    @Test("SongsView — iPad Landscape — Empty State — Light Mode")
    func songsEmptyiPadLandscapeLight() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let viewModel = makeViewModel()
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
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

    @Test("SongsView — iPad Landscape — Empty State — Dark Mode")
    func songsEmptyiPadLandscapeDark() {
        let router = Router()
        let playerViewModel = PlayerViewModel(player: MockPlayer(), cacheRepository: MockCacheRepository())
        let viewModel = makeViewModel()
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
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
