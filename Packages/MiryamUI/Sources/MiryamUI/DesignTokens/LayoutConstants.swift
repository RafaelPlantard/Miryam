import SwiftUI

/// Reusable layout constants with semantic meaning.
public enum Layout: Sendable {
    /// Player view dimensions.
    public enum Player {
        public static let artworkSizeCompact: CGFloat = 264
        public static let artworkSizeRegular: CGFloat = 360
        public static let artworkSizeiPadLandscape: CGFloat = 286
        public static let maxContentWidth: CGFloat = 600
        public static let artworkCornerRadius: CGFloat = 32
        public static let controlSpacing: CGFloat = 40
        public static let minTapTarget: CGFloat = 44
        public static let playButtonSize: CGFloat = 72
        public static let trackHeight: CGFloat = 8
        public static let handleSize: CGFloat = 24
        public static let queuePanelWidth: CGFloat = 288
    }

    /// Song row / list item dimensions.
    public enum SongRow {
        public static let thumbnailSize: CGFloat = 44
        public static let thumbnailCornerRadius: CGFloat = 8
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

    /// Album view dimensions.
    public enum Album {
        public static let artworkSizeCompact: CGFloat = 120
        public static let artworkSizeRegular: CGFloat = 160
        public static let cornerRadius: CGFloat = 20
        public static let trackRowArtworkSize: CGFloat = 44
        public static let trackRowCornerRadius: CGFloat = 8
    }

    /// More options sheet dimensions.
    public enum MoreOptions {
        public static let grabberCornerRadius: CGFloat = 2.5
        public static let grabberWidth: CGFloat = 56
        public static let grabberHeight: CGFloat = 5
        public static let songHeaderHeight: CGFloat = 67
        public static let actionButtonMinHeight: CGFloat = 56
        public static let iconFrameWidth: CGFloat = 24
        /// Content-fitting sheet height: grabber area + header + action + bottom padding.
        public static let sheetHeight: CGFloat = 230
    }
}
