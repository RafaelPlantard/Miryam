import SwiftUI
import MiryamCore
import MiryamFeatures
import MiryamUI
import MiryamPersistence

@main
struct MiryamVisionApp: App {
    @State private var container: DependencyContainer?
    @State private var router = Router()

    var body: some Scene {
        WindowGroup {
            Group {
                if let container {
                    NavigationStack(path: Bindable(router).path) {
                        SongsView(viewModel: container.makeSongsViewModel())
                            .navigationDestination(for: AppRoute.self) { route in
                                switch route {
                                case .player(let song):
                                    let playerVM = container.makePlayerViewModel()
                                    PlayerView(viewModel: playerVM)
                                        .environment(router)
                                        .task { await playerVM.play(song) }
                                case .album(let album):
                                    AlbumView(
                                        viewModel: container.makeAlbumViewModel(album: album),
                                        onPlaySong: { song in
                                            router.navigate(to: .player(song))
                                        }
                                    )
                                    .environment(router)
                                }
                            }
                    }
                    .environment(router)
                } else {
                    ProgressView("Loading...")
                }
            }
            .task {
                FontRegistration.registerFonts()
                do {
                    container = try DependencyContainer()
                } catch {
                    fatalError("Failed to create DependencyContainer: \(error)")
                }
            }
        }
    }
}
