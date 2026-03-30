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
        let viewModel = makeViewModel()
        let view = NavigationStack {
            SongsView(viewModel: viewModel)
        }
        .environment(router)

        let controller = SnapshotHelper.hostingController(
            for: view,
            interfaceStyle: .light
        )
        assertSnapshot(
            of: controller,
            as: .image(on: .iPadPro11(.portrait)),
            record: false
        )
    }

    @Test("SongsView — iPad — Empty State — Dark Mode")
    func songsEmptyiPadDark() {
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
        assertSnapshot(
            of: controller,
            as: .image(on: .iPadPro11(.portrait)),
            record: false
        )
    }

    @Test("SongsView — iPad — With Results — Light Mode")
    func songsWithResultsiPadLight() {
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
        assertSnapshot(
            of: controller,
            as: .image(on: .iPadPro11(.portrait)),
            record: false
        )
    }

    @Test("SongsView — iPad — With Results — Dark Mode")
    func songsWithResultsiPadDark() {
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
        assertSnapshot(
            of: controller,
            as: .image(on: .iPadPro11(.portrait)),
            record: false
        )
    }

    @Test("SongsView — iPad Landscape — With Results — Dark Mode")
    func songsWithResultsiPadLandscapeDark() {
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
        assertSnapshot(
            of: controller,
            as: .image(on: .iPadPro11(.landscape)),
            record: false
        )
    }
}

#endif // os(iOS)
