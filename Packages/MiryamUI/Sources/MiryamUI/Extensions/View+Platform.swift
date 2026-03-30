import MiryamCore
import MiryamFeatures
import SwiftUI

// MARK: - Platform-Adaptive View Modifiers
//
// Centralises all `#if os()` checks for SwiftUI modifiers that are
// unavailable on certain platforms. Views use these extensions instead
// of scattering conditional compilation throughout the codebase.

extension View {

    /// Applies `.navigationBarTitleDisplayMode(.inline)` on platforms that support it.
    @ViewBuilder
    public func inlineNavigationTitle() -> some View {
        #if !os(macOS) && !os(tvOS)
            self.navigationBarTitleDisplayMode(.inline)
        #else
            self
        #endif
    }

    /// Applies `.listRowSeparator(.hidden)` on platforms that support it.
    @ViewBuilder
    public func hideRowSeparator() -> some View {
        #if !os(watchOS) && !os(tvOS)
            self.listRowSeparator(.hidden)
        #else
            self
        #endif
    }

    /// Adds a ••• toolbar button that opens the MoreOptions sheet on supported platforms.
    @ViewBuilder
    public func playerToolbar(song: Song?, router: Router) -> some View {
        #if !os(tvOS)
            self.toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let song {
                        Button {
                            router.presentSheet(.moreOptions(song))
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.body)
                                .foregroundStyle(Color._miryamIconSecondary)
                                .frame(width: 36, height: 36)
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
