import MiryamCore
import MiryamFeatures
import MiryamUI
import SwiftUI

@main
struct MiryamWatchApp: App {
    @State private var container: WatchDependencyContainer?
    @State private var albumRoute: Album?

    var body: some Scene {
        WindowGroup {
            if let container {
                NavigationStack {
                    WatchNowPlayingView(viewModel: container.playerViewModel)
                        .navigationDestination(item: $albumRoute) { album in
                            WatchAlbumView(
                                viewModel: container.makeAlbumViewModel(album: album),
                                onPlaySong: { song in
                                    Task { await container.playerViewModel.play(song) }
                                    albumRoute = nil
                                }
                            )
                        }
                }
            } else {
                ProgressView()
                    .task {
                        container = WatchDependencyContainer()
                    }
            }
        }
    }
}
