import Foundation

/// Shared constants used across Miryam packages.
public enum Constants: Sendable {
    /// Player-related timing constants.
    public enum Player: Sendable {
        /// Seconds to skip forward/backward.
        public static let skipInterval: TimeInterval = 15
        /// Periodic time observer interval in seconds.
        public static let timeObserverInterval: TimeInterval = 0.05
    }

    /// Search and pagination defaults.
    public enum Search: Sendable {
        /// Number of results per page.
        public static let pageLimit: Int = 25
        /// Number of recently played songs to display.
        public static let recentlyPlayedLimit: Int = 10
        /// Debounce interval for search input in milliseconds.
        public static let debounceMilliseconds: Int = 300
    }

    /// iTunes artwork URL constants.
    public enum Artwork: Sendable {
        /// The default thumbnail size pattern returned by the iTunes API.
        public static let defaultSizePattern = "100x100"
    }

    /// Fallback display strings for missing metadata.
    public enum Fallback: Sendable {
        public static let artistName = "Unknown Artist"
        public static let albumName = "Unknown Album"
        public static let genre = "Unknown"
    }
}
