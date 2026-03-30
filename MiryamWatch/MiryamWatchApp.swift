import SwiftUI
import MiryamCore
import MiryamFeatures
import MiryamUI

@main
struct MiryamWatchApp: App {
    @State private var container: WatchDependencyContainer?

    var body: some Scene {
        WindowGroup {
            if let container {
                WatchNowPlayingView(viewModel: container.playerViewModel)
            } else {
                ProgressView()
                    .task {
                        container = WatchDependencyContainer()
                    }
            }
        }
    }
}
