import SwiftUI

/// A draggable (iOS/macOS/visionOS) or static (tvOS) timeline handle
/// that abstracts platform gesture differences.
struct TimelineHandle: View {
    let progress: Double
    let trackWidth: CGFloat
    let onSeek: @MainActor (Double) -> Void

    #if !os(tvOS)
        @GestureState private var isDragging = false
    #endif

    private var offsetX: CGFloat {
        max(0, trackWidth * progress - 4)
    }

    var body: some View {
        #if os(tvOS)
            Circle()
                .fill(Color._miryamAccent)
                .frame(width: 8, height: 8)
                .offset(x: offsetX)
        #else
            Circle()
                .fill(Color._miryamAccent)
                .frame(width: isDragging ? 16 : 8, height: isDragging ? 16 : 8)
                .offset(x: offsetX)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating($isDragging) { _, state, _ in
                            state = true
                        }
                        .onChanged { value in
                            let seekProgress = max(0, min(1, value.location.x / trackWidth))
                            onSeek(seekProgress)
                        }
                )
        #endif
    }
}
