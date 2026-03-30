import SwiftUI

/// Semantic color tokens matching Figma design spec.
/// Dark values are from Figma; light values are adapted.
public extension Color {
    static let miryamBackground = Color("miryamBackground", bundle: .module)
    static let miryamSurface = Color("miryamSurface", bundle: .module)
    static let miryamSurfaceSecondary = Color("miryamSurfaceSecondary", bundle: .module)
    static let miryamLabel = Color("miryamLabel", bundle: .module)
    static let miryamLabelSecondary = Color("miryamLabelSecondary", bundle: .module)
    static let miryamLabelTertiary = Color("miryamLabelTertiary", bundle: .module)
    static let miryamIconPrimary = Color("miryamIconPrimary", bundle: .module)
    static let miryamAccent = Color("miryamAccent", bundle: .module)
}
