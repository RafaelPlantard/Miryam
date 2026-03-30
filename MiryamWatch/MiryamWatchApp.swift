import MiryamCore
import MiryamFeatures
import MiryamUI
import SwiftUI

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
