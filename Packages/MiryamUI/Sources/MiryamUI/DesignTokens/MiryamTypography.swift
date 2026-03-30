import SwiftUI

/// Typography tokens using DM Sans font family.
public extension Font {
    /// Miryam typography namespace.
    enum miryam { // swiftlint:disable:this type_name
        /// Display 32 — SemiBold 600, size 32 (Player song title)
        public static let display32 = Font.custom("DMSans-SemiBold", size: 32)

        /// Display 20 — SemiBold 600, size 20 (Album title)
        public static let display20 = Font.custom("DMSans-SemiBold", size: 20)

        /// Display 18 — SemiBold 600, size 18, line height 1.08
        public static let display = Font.custom("DMSans-SemiBold", size: 18)

        /// Body Large 16 — Medium 500, size 16, line height 1.2
        public static let bodyLarge = Font.custom("DMSans-Medium", size: 16)

        /// Body Small 14 — Medium 500, size 14, line height 1.2
        public static let bodySmall = Font.custom("DMSans-Medium", size: 14)

        /// Caption 12 — Medium 500, size 12, line height 1.4
        public static let caption = Font.custom("DMSans-Medium", size: 12)

        /// Icon Large — size 60 (Player artwork placeholder)
        public static let iconLarge = Font.system(size: 60)

        /// Icon Medium — size 48 (Empty state icons)
        public static let iconMedium = Font.system(size: 48)

        /// Icon Small — size 40 (Album artwork placeholder)
        public static let iconSmall = Font.system(size: 40)

        /// Control Large — size 28 (Play/pause button)
        public static let controlLarge = Font.system(size: 28)

        /// Control Regular — size 20 (Skip buttons)
        public static let controlRegular = Font.system(size: 20)
    }
}
