import SwiftUI

/// Animated equalizer bars indicating the currently playing song.
public struct NowPlayingIndicator: View {
    let isAnimating: Bool

    private let barCount = 5
    private let barWidth: CGFloat = 3
    private let spacing: CGFloat = 2
    private let maxHeight: CGFloat = 16
    private let minHeight: CGFloat = 3

    // Each bar gets a different phase offset for a natural look
    private let phases: [Double] = [0, 0.2, 0.4, 0.15, 0.35]

    public init(isAnimating: Bool = true) {
        self.isAnimating = isAnimating
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: spacing) {
            ForEach(0 ..< barCount, id: \.self) { index in
                bar(phase: phases[index])
            }
        }
        .frame(width: CGFloat(barCount) * barWidth + CGFloat(barCount - 1) * spacing, height: maxHeight)
        .accessibilityHidden(true)
    }

    private func bar(phase: Double) -> some View {
        RoundedRectangle(cornerRadius: barWidth / 2)
            .fill(Color._miryamAccent)
            .frame(width: barWidth)
            .frame(height: isAnimating ? maxHeight : minHeight)
            .animation(
                isAnimating
                    ? .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                    .delay(phase)
                    : .easeInOut(duration: 0.3),
                value: isAnimating
            )
    }
}
