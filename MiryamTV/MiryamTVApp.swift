import MiryamCore
import MiryamFeatures
import MiryamPersistence
import MiryamUI
import SwiftUI

@main
struct MiryamTVApp: App {
    @State private var container: DependencyContainer?
    @State private var containerError: Error?
    @State private var router = Router()
    @State private var playerViewModel: PlayerViewModel?

    var body: some Scene {
        WindowGroup {
            Group {
                if let container, let playerViewModel {
                    NavigationStack(path: Bindable(router).path) {
                        SongsView(viewModel: container.makeSongsViewModel())
                            .navigationDestination(for: AppRoute.self) { route in
                                switch route {
                                case let .player(song):
                                    PlayerView(viewModel: playerViewModel)
                                        .environment(router)
                                        .task { await playerViewModel.play(song) }
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
                    playerViewModel = di.makePlayerViewModel()
                } catch {
                    containerError = error
                }
            }
        }
    }
}
