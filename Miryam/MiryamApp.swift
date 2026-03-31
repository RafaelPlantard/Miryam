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
                    ContentUnavailableView(
                        "Unable to Load",
                        systemImage: "exclamationmark.triangle",
                        description: Text(containerError.localizedDescription)
                    )
                } else {
                    ProgressView("Loading...")
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
                    songsViewModel = di.makeSongsViewModel()
                    playerViewModel = di.makePlayerViewModel()
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
                            .task { await playerViewModel.play(song) }
                    case let .album(album):
                        AlbumView(
                            viewModel: container.makeAlbumViewModel(album: album),
                            onPlaySong: { song in
                                Task { await playerViewModel.play(song) }
                            }
                        )
                        .environment(router)
                    }
                }
        }
        .environment(router)
        .environment(playerViewModel)
        .sheet(item: $router.presentedSheet) { sheet in
            switch sheet {
            case let .moreOptions(song):
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
        }
        .modelContainer(container.modelContainer)
    }

    // MARK: - UI Test Support

    #if DEBUG
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
