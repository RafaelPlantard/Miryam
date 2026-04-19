import MiryamCore
import MiryamFeatures
import MiryamNetworking
import MiryamPersistence
import MiryamPlayer
import MiryamUI
import SwiftData
import SwiftUI

@main
struct MiryamApp: App {
    @State private var showSplash = true
    @State private var container: DependencyContainer?
    @State private var containerError: Error?
    @State private var router = Router()
    @State private var songsViewModel: SongsViewModel?
    @State private var playerViewModel: PlayerViewModel?
    @State private var phoneSession: PhoneSessionService?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView {
                        withAnimation {
                            showSplash = false
                        }
                    }
                } else if let container, let songsViewModel, let playerViewModel {
                    mainContent(
                        container: container,
                        songsViewModel: songsViewModel,
                        playerViewModel: playerViewModel
                    )
                } else if let containerError {
                    ContentUnavailableView {
                        Label {
                            Text(L10n.unableToLoad)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle")
                        }
                    } description: {
                        Text(containerError.localizedDescription)
                    }
                } else {
                    ProgressView {
                        Text(L10n.loading)
                    }
                }
            }
            .task {
                FontRegistration.registerFonts()
                do {
                    let di: DependencyContainer
                    #if DEBUG
                        if ProcessInfo.processInfo.arguments.contains("-UITestMode") {
                            di = try Self.makeTestContainer()
                        } else {
                            di = try DependencyContainer()
                        }
                    #else
                        di = try DependencyContainer()
                    #endif
                    container = di
                    let svm = di.makeSongsViewModel()
                    #if DEBUG
                        if ProcessInfo.processInfo.arguments.contains("-UITestMode") {
                            await Self.primeUITestSongs(in: svm, using: di)
                        }
                    #endif
                    songsViewModel = svm
                    let pvm = di.makePlayerViewModel()
                    playerViewModel = pvm
                    let player = di.player
                    Task {
                        await player.setTrackNavigationCallbacks(
                            onNext: { await pvm.skipToNext() },
                            onPrevious: { await pvm.skipToPrevious() }
                        )
                    }
                    let session = PhoneSessionService(player: player)
                    phoneSession = session
                    pvm.onStateChanged = { state in
                        PhoneSessionService.sendStateToWatch(state)
                    }
                } catch {
                    containerError = error
                }
            }
        }
    }

    @ViewBuilder
    private func mainContent(
        container: DependencyContainer,
        songsViewModel: SongsViewModel,
        playerViewModel: PlayerViewModel
    ) -> some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            SongsView(viewModel: songsViewModel)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case let .player(song):
                        PlayerView(viewModel: playerViewModel)
                            .environment(router)
                            .task {
                                // Queue is set by whichever view triggered the
                                // navigation (SongsView → search list;
                                // AlbumView → album tracks), so Next/Previous
                                // reflects the actual list the user was in.
                                await playerViewModel.play(song)
                            }
                    case let .album(album):
                        AlbumView(
                            viewModel: container.makeAlbumViewModel(album: album)
                        )
                        .environment(router)
                    }
                }
        }
        .environment(router)
        .environment(playerViewModel)
        .sheet(item: Binding(
            get: { horizontalSizeClass == .compact ? router.presentedSheet : nil },
            set: { router.presentedSheet = $0 }
        )) { sheet in
            switch sheet {
            case let .moreOptions(song):
                moreOptionsContent(song: song)
            }
        }
        .popover(item: Binding(
            get: { horizontalSizeClass != .compact ? router.presentedSheet : nil },
            set: { router.presentedSheet = $0 }
        )) { sheet in
            switch sheet {
            case let .moreOptions(song):
                moreOptionsContent(song: song)
            }
        }
        .modelContainer(container.modelContainer)
    }

    @ViewBuilder
    private func moreOptionsContent(song: Song) -> some View {
        MoreOptionsView(song: song) {
            let album = Album(
                id: song.albumId,
                name: song.albumName,
                artistName: song.artistName,
                artworkURL: song.artworkURL,
                trackCount: 0,
                releaseDate: nil,
                genre: ""
            )
            router.popToRoot()
            router.navigate(to: .album(album))
        }
        .environment(router)
    }

    // MARK: - UI Test Support

    #if DEBUG
        @MainActor
        private static func primeUITestSongs(
            in songsViewModel: SongsViewModel,
            using container: DependencyContainer
        ) async {
            do {
                let result = try await container.songRepository.searchSongs(
                    query: "Adele",
                    limit: Constants.Search.pageLimit,
                    offset: 0
                )
                songsViewModel.songs = result.songs
                songsViewModel.hasMorePages = result.songs.count == Constants.Search.pageLimit
            } catch {
                // Keep UITests resilient even if the fixture bootstrap fails.
            }
        }

        private static func makeTestContainer() throws -> DependencyContainer {
            StubURLProtocol.stubbedResponses = [
                (pattern: "term=xyznonexistent", fixture: "search_empty"),
                (pattern: "/search", fixture: "search_adele"),
                (pattern: "/lookup", fixture: "lookup_album"),
            ]

            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [StubURLProtocol.self]
            let session = URLSession(configuration: config)

            let httpClient = HTTPClient(session: session, maxRetries: 0)
            let songRepository = SongRepository(httpClient: httpClient)
            let modelContainer = try PersistenceContainer.makeTestContainer()
            let cacheRepository = CacheActor(modelContainer: modelContainer)
            let player = AudioPlayer()

            return DependencyContainer(
                songRepository: songRepository,
                cacheRepository: cacheRepository,
                player: player,
                modelContainer: modelContainer
            )
        }
    #endif
}
