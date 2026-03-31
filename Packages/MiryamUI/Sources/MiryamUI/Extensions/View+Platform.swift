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

    /// Hides the navigation bar for root-level custom Figma headers where supported.
    @ViewBuilder
    func hideNavigationBarChrome() -> some View {
        #if !os(macOS) && !os(tvOS) && !os(watchOS)
            toolbar(.hidden, for: .navigationBar)
        #else
            self
        #endif
    }

    /// Adds a ••• toolbar button that opens the MoreOptions sheet on supported platforms.
    @ViewBuilder
    func playerToolbar(song: Song?, router: Router) -> some View {
        #if !os(macOS) && !os(tvOS)
            toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let song {
                        Button {
                            router.presentSheet(.moreOptions(song))
                        } label: {
                            Image(symbol: .ellipsis)
                                .font(.body)
                                .foregroundStyle(Color._miryamIconSecondary)
                                .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
                                .contentShape(Rectangle())
                        }
                        .accessibilityIdentifier(AccessibilityID.moreOptionsButton.rawValue)
                        .accessibilityLabel(Text(L10n.moreOptions))
                    }
                }
            }
        #else
            self
        #endif
    }
}
