import SwiftUI

/// Typography tokens using DM Sans font family.
public extension Font {
    /// Miryam typography namespace.
    enum miryam {
        /// Display 18 — SemiBold 600, size 18, line height 1.08
        public static let display = Font.custom("DMSans-SemiBold", size: 18)

        /// Body Large 16 — Medium 500, size 16, line height 1.2
        public static let bodyLarge = Font.custom("DMSans-Medium", size: 16)

        /// Body Small 14 — Medium 500, size 14, line height 1.2
        public static let bodySmall = Font.custom("DMSans-Medium", size: 14)
    }
}
