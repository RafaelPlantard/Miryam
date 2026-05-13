import SwiftUI

/// Hardcoded color fallbacks — used until Asset Catalog colors are set up in Xcode.
/// These provide correct dark/light adaptive behavior.
public extension Color {
    // swiftlint:disable identifier_name

    // On watchOS the Miryam `Color(light:dark:)` init can't adapt at runtime
    // (no UIColor.init(dynamicProvider:) there) and falls through to the
    // light variant. That makes labels (.black) invisible on the dark watch
    // background, and would leave white labels on a light-gray surface
    // after the foreground fix. Watch is effectively always dark mode in
    // practice — pin all tokens to their dark variants there, and use
    // SwiftUI semantic colors for foreground roles so they stay adaptive
    // if the user ever toggles light mode.
    #if os(watchOS)
        static let _miryamBackground: Color = .init(hex: "000000")
        static let _miryamSurface: Color = .init(hex: "262626").opacity(0.80)
        static let _miryamSurfaceSecondary: Color = .init(hex: "2C2C2E")
        static let _miryamLabel: Color = .primary
        static let _miryamLabelSecondary: Color = .secondary
        static let _miryamLabelTertiary: Color = .secondary.opacity(0.5)
        static let _miryamIconPrimary: Color = .primary
        static let _miryamIconSecondary: Color = .secondary
        static let _miryamSubtitle: Color = .secondary
        static let _miryamAccent: Color = .init(hex: "0086A0")
    #else
        static let _miryamBackground = Color(light: Color(hex: "F5F5F7"), dark: Color(hex: "000000"))
        static let _miryamSurface = Color(light: Color(hex: "FFFFFF").opacity(0.85), dark: Color(hex: "262626").opacity(0.80))
        static let _miryamSurfaceSecondary = Color(light: Color(hex: "E5E5EA"), dark: Color(hex: "2C2C2E"))
        static let _miryamLabel = Color(light: .black, dark: .white)
        static let _miryamLabelSecondary = Color(light: Color(hex: "6C6C70"), dark: Color(hex: "A8A8A8"))
        static let _miryamLabelTertiary = Color(light: .black.opacity(0.25), dark: .white.opacity(0.25))
        static let _miryamIconPrimary = Color(light: Color(hex: "1C1C1E"), dark: .white)
        static let _miryamIconSecondary = Color(light: Color(hex: "737373"), dark: Color(hex: "545454"))
        static let _miryamSubtitle = Color(light: Color(hex: "545454"), dark: Color(hex: "737373"))
        static let _miryamAccent = Color(light: Color(hex: "006B80"), dark: Color(hex: "0086A0"))
    #endif

    // swiftlint:enable identifier_name
}

extension Color {
    /// Create an adaptive color from light and dark variants.
    init(light: Color, dark: Color) {
        #if canImport(UIKit) && !os(watchOS)
            self.init(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(dark)
                    : UIColor(light)
            })
        #elseif canImport(AppKit)
            self.init(nsColor: NSColor(name: nil) { appearance in
                appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                    ? NSColor(dark)
                    : NSColor(light)
            })
        #else
            self = light
        #endif
    }
}
