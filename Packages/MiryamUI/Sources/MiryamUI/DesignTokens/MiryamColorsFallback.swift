import SwiftUI

/// Hardcoded color fallbacks — used until Asset Catalog colors are set up in Xcode.
/// These provide correct dark/light adaptive behavior.
public extension Color {
    // swiftlint:disable identifier_name
    static let _miryamBackground = Color(light: Color(hex: "F5F5F7"), dark: Color(hex: "0D1117"))
    static let _miryamSurface = Color(light: Color(hex: "FFFFFF").opacity(0.85), dark: Color(hex: "262626").opacity(0.80))
    static let _miryamSurfaceSecondary = Color(light: Color(hex: "E5E5EA"), dark: Color(hex: "2C2C2E"))
    static let _miryamLabel = Color(light: .black, dark: .white)
    static let _miryamLabelSecondary = Color(light: Color(hex: "6C6C70"), dark: Color(hex: "8E8E93"))
    static let _miryamLabelTertiary = Color(light: .black.opacity(0.25), dark: .white.opacity(0.25))
    static let _miryamIconPrimary = Color(light: Color(hex: "1C1C1E"), dark: .white)
    static let _miryamAccent = Color(light: Color(hex: "006B80"), dark: Color(hex: "0086A0"))
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
