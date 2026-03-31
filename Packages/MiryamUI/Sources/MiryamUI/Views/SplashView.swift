import Foundation
import SwiftUI

public struct SplashView: View {
    @State private var isActive = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let onComplete: () -> Void

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            LinearGradient.spotlight
                .ignoresSafeArea()

            Image("musical-note", bundle: .module)
                .resizable()
                .frame(width: Layout.Splash.logoSize, height: Layout.Splash.logoSize)
                .opacity(isActive ? 1 : 0)
                .scaleEffect(isActive ? 1 : 0.8)
                .accessibilityLabel(Text(L10n.appName))
        }
        .accessibilityIdentifier(AccessibilityID.splashScreen.rawValue)
        .onAppear {
            if reduceMotion {
                isActive = true
            } else {
                withAnimation(.easeOut(duration: Layout.Splash.animationDuration)) {
                    isActive = true
                }
            }
            scheduleTransition()
        }
    }

    private func scheduleTransition() {
        guard !ProcessInfo.processInfo.arguments.contains("-UITestHoldSplash") else { return }

        Task {
            try? await Task.sleep(for: .seconds(Layout.Splash.transitionDelay))
            await MainActor.run {
                onComplete()
            }
        }
    }
}
