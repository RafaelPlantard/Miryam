#if os(iOS)
import Testing
import SnapshotTesting
import SwiftUI
import UIKit
@testable import MiryamUI
@testable import MiryamFeatures
import MiryamCore

@Suite("SongsView Snapshots")
@MainActor
struct SongsViewSnapshotTests {

    private func makeViewModel() -> SongsViewModel {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        return SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)
    }

    // MARK: Empty State

    @Test("SongsView — Empty State — Light Mode")
    func songsEmptyLight() {
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("SongsView — Empty State — Dark Mode")
    func songsEmptyDark() {
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    // MARK: Loading State

    @Test("SongsView — Loading State — Light Mode")
    func songsLoadingLight() {
        let router = Router()
        let viewModel = makeViewModel()
        viewModel.isLoading = true
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("SongsView — Loading State — Dark Mode")
    func songsLoadingDark() {
        let router = Router()
        let viewModel = makeViewModel()
        viewModel.isLoading = true
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    // MARK: With Results

    @Test("SongsView — With Results — Light Mode")
    func songsWithResultsLight() {
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("SongsView — With Results — Dark Mode")
    func songsWithResultsDark() {
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    // MARK: No Results

    @Test("SongsView — No Results — Light Mode")
    func songsNoResultsLight() {
        let router = Router()
        let viewModel = makeViewModel()
        viewModel.songs = []
        viewModel.searchQuery = "xyznonexistent"
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("SongsView — No Results — Dark Mode")
    func songsNoResultsDark() {
        let router = Router()
        let viewModel = makeViewModel()
        viewModel.songs = []
        viewModel.searchQuery = "xyznonexistent"
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    // MARK: Error State

    @Test("SongsView — Error State — Light Mode")
    func songsErrorLight() {
        let router = Router()
        let viewModel = makeViewModel()
        viewModel.error = .networkError("Connection failed")
        viewModel.songs = []
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }

    @Test("SongsView — Error State — Dark Mode")
    func songsErrorDark() {
        let router = Router()
        let viewModel = makeViewModel()
        viewModel.error = .networkError("Connection failed")
        viewModel.songs = []
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
            as: .image(on: .iPhone13Pro, precision: 0.995, perceptualPrecision: 0.98),
            record: false
        )
    }
}

#endif // os(iOS)
