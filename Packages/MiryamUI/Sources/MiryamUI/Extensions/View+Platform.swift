import MiryamCore
import MiryamFeatures
import SwiftUI

// MARK: - Platform-Adaptive View Modifiers

// Centralises all `#if os()` checks for SwiftUI modifiers that are
// unavailable on certain platforms. Views use these extensions instead
// of scattering conditional compilation throughout the codebase.

public extension View {
    /// Applies `.navigationBarTitleDisplayMode(.inline)` on platforms that support it.
    @ViewBuilder
    func inlineNavigationTitle() -> some View {
        #if !os(macOS) && !os(tvOS)
            navigationBarTitleDisplayMode(.inline)
        #else
            self
        #endif
    }

    /// Applies `.listRowSeparator(.hidden)` on platforms that support it.
    @ViewBuilder
    func hideRowSeparator() -> some View {
        #if !os(watchOS) && !os(tvOS)
            listRowSeparator(.hidden)
        #else
            self
        #endif
    }

    /// Adds a ••• toolbar button that opens the MoreOptions sheet on supported platforms.
    @ViewBuilder
    func playerToolbar(song: Song?, router: Router) -> some View {
        #if !os(tvOS)
            toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let song {
                        Button {
                            router.presentSheet(.moreOptions(song))
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.body)
                                .foregroundStyle(Color._miryamIconSecondary)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .accessibilityIdentifier(AccessibilityID.moreOptionsButton.rawValue)
                        .accessibilityLabel("More options")
                    }
                }
            }
        #else
            self
        #endif
    }
}
