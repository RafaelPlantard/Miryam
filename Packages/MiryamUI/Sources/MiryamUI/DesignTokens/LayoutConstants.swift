import SwiftUI

/// Reusable layout constants with semantic meaning.
public enum Layout: Sendable {
    /// Player view dimensions.
    public enum Player {
        public static let artworkSizeCompact: CGFloat = 302
        public static let artworkSizeRegular: CGFloat = 230
        public static let artworkSizeiPadLandscape: CGFloat = 200
        public static let maxContentWidth: CGFloat = 600
        public static let artworkCornerRadius: CGFloat = 28
        public static let compactHorizontalPadding: CGFloat = 32
        public static let compactTopPadding: CGFloat = 20
        public static let compactBottomPadding: CGFloat = 28
        #if os(tvOS)
            public static let controlSpacing: CGFloat = 48
            public static let minTapTarget: CGFloat = 70
            public static let playButtonSize: CGFloat = 80
            public static let secondaryControlSize: CGFloat = 70
        #else
            public static let controlSpacing: CGFloat = 24
            public static let minTapTarget: CGFloat = 44
            public static let playButtonSize: CGFloat = 56
            public static let secondaryControlSize: CGFloat = 48
        #endif
        public static let trackHeight: CGFloat = 6
        public static let handleSize: CGFloat = 24
        public static let queuePanelWidth: CGFloat = 320
        public static let compactHeaderHeight: CGFloat = 48
        public static let compactMetadataSpacing: CGFloat = 4
        public static let compactBottomSectionSpacing: CGFloat = 18
        public static let compactArtworkTopSpacing: CGFloat = 24
    }

    /// Song row / list item dimensions.
    public enum SongRow {
        #if os(tvOS)
            // tvOS focus engine scales focused content ~1.08x and adds a glow/
            // shadow halo around it. The previous 80pt row + 12pt vertical gap
            // left the scaled row (≈86pt) plus its halo overflowing into the
            // adjacent row. Bump the row to 104pt and the gap to 28pt so the
            // focus effect fits comfortably without visual collision, and
            // scale the thumbnail/buttons so the row still looks balanced at
            // 10-foot viewing distance.
            public static let rowHeight: CGFloat = 104
            public static let horizontalPadding: CGFloat = 48
            public static let verticalPadding: CGFloat = 28
            public static let thumbnailSize: CGFloat = 72
            public static let thumbnailCornerRadius: CGFloat = 12
            public static let textSpacing: CGFloat = 4
            public static let contentSpacing: CGFloat = 24
            public static let moreButtonSize: CGFloat = 56
            public static let separatorLeadingInset: CGFloat = 144
        #else
            public static let rowHeight: CGFloat = 68
            public static let horizontalPadding: CGFloat = 24
            public static let verticalPadding: CGFloat = 0
            public static let thumbnailSize: CGFloat = 52
            public static let thumbnailCornerRadius: CGFloat = 8
            public static let textSpacing: CGFloat = 4
            public static let contentSpacing: CGFloat = 16
            public static let moreButtonSize: CGFloat = 36
            public static let separatorLeadingInset: CGFloat = 92
        #endif
    }

    /// Recently played card dimensions.
    public enum RecentlyPlayed {
        public static let cardSize: CGFloat = 140
        public static let cornerRadius: CGFloat = 12
    }

    /// Splash screen.
    public enum Splash {
        public static let logoSize: CGFloat = 100
        public static let animationDuration: Double = 0.6
        public static let transitionDelay: Double = 1.5
    }

    /// Songs screen layout metrics.
    public enum Songs {
        #if os(tvOS)
            public static let titleTopPadding: CGFloat = 40
            public static let titleHorizontalPadding: CGFloat = 48
            public static let titleBottomPadding: CGFloat = 16
            public static let searchHorizontalPadding: CGFloat = 48
            public static let searchHeight: CGFloat = 66
            public static let searchBottomPadding: CGFloat = 16
            public static let sectionTopPadding: CGFloat = 16
            public static let sectionHorizontalPadding: CGFloat = 48
            public static let searchCornerRadius: CGFloat = 16
            public static let searchIconSpacing: CGFloat = 12
            public static let searchInnerHorizontalPadding: CGFloat = 24
        #else
            public static let titleTopPadding: CGFloat = 20
            public static let titleHorizontalPadding: CGFloat = 24
            public static let titleBottomPadding: CGFloat = 8
            public static let searchHorizontalPadding: CGFloat = 20
            public static let searchHeight: CGFloat = 44
            public static let searchBottomPadding: CGFloat = 8
            public static let sectionTopPadding: CGFloat = 8
            public static let sectionHorizontalPadding: CGFloat = 24
            public static let searchCornerRadius: CGFloat = 12
            public static let searchIconSpacing: CGFloat = 8
            public static let searchInnerHorizontalPadding: CGFloat = 16
        #endif
    }

    /// Album view dimensions.
    public enum Album {
        public static let artworkSizeCompact: CGFloat = 156
        public static let artworkSizeRegular: CGFloat = 220
        public static let cornerRadius: CGFloat = 20
        public static let trackRowArtworkSize: CGFloat = 52
        public static let trackRowArtworkSizeiPad: CGFloat = 78
        public static let trackRowCornerRadius: CGFloat = 8
        public static let trackRowCornerRadiusiPad: CGFloat = 10
        public static let headerTopPadding: CGFloat = 24
        public static let headerSpacing: CGFloat = 10
    }

    /// More options sheet dimensions.
    public enum MoreOptions {
        public static let grabberCornerRadius: CGFloat = 2.5
        public static let grabberWidth: CGFloat = 56
        public static let grabberHeight: CGFloat = 5
        public static let songHeaderHeight: CGFloat = 67
        public static let contentTopSpacing: CGFloat = 14
        public static let actionButtonMinHeight: CGFloat = 56
        public static let iconFrameWidth: CGFloat = 24
        public static let bottomPadding: CGFloat = 48
        /// Content-fitting sheet height: grabber(10) + header(67) + spacing(14) + action(56) + bottom(48) ≈ Figma 199.
        public static let sheetHeight: CGFloat = 200
    }
}
