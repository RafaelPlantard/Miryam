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

            Text("Miryam")
                .font(.miryam.display)
                .foregroundStyle(.white)
                .opacity(isActive ? 1 : 0)
                .scaleEffect(isActive ? 1 : 0.8)
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
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                onComplete()
            }
        }
    }
}
