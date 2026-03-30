import MiryamCore
import MiryamFeatures
import MiryamPersistence
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
                    let di = try DependencyContainer()
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
                    router.navigate(to: .album(album))
                }
                .environment(router)
            }
        }
        .modelContainer(container.modelContainer)
    }
}
