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
                .frame(width: 100, height: 100)
                .opacity(isActive ? 1 : 0)
                .scaleEffect(isActive ? 1 : 0.8)
                .accessibilityLabel("Miryam")
        }
        .onAppear {
            if reduceMotion {
                isActive = true
            } else {
                withAnimation(.easeOut(duration: 0.6)) {
                    isActive = true
                }
            }
            scheduleTransition()
        }
    }

    private func scheduleTransition() {
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            await MainActor.run {
                onComplete()
            }
        }
    }
}
