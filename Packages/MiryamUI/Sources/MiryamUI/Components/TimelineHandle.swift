import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

/// A draggable (iOS/macOS/visionOS) or static (tvOS) timeline handle
/// that abstracts platform gesture differences.
struct TimelineHandle: View {
    let progress: Double
    let trackWidth: CGFloat
    let onSeek: @MainActor (Double) -> Void

    #if !os(tvOS)
        @GestureState private var isDragging = false
    #endif

    private var handleSize: CGFloat {
        Layout.Player.handleSize
    }

    private var offsetX: CGFloat {
        max(0, trackWidth * progress - handleSize / 2)
    }

    var body: some View {
        #if os(tvOS)
            Circle()
                .fill(Color._miryamAccent)
                .frame(width: handleSize, height: handleSize)
                .offset(x: offsetX)
        #else
            Circle()
                .fill(Color._miryamAccent)
                .frame(
                    width: isDragging ? handleSize + 4 : handleSize,
                    height: isDragging ? handleSize + 4 : handleSize
                )
                .offset(x: offsetX)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating($isDragging) { _, state, _ in
                            if !state {
                                triggerHaptic()
                            }
                            state = true
                        }
                        .onChanged { value in
                            let seekProgress = max(0, min(1, value.location.x / trackWidth))
                            onSeek(seekProgress)
                        }
                        .onEnded { _ in
                            triggerHaptic()
                        }
                )
        #endif
    }

    #if os(iOS) || os(visionOS)
        private func triggerHaptic() {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    #else
        private func triggerHaptic() {}
    #endif
}
