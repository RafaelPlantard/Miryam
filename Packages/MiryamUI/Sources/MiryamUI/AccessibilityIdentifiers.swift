import Foundation

/// Centralized accessibility identifiers for UI testing.
public enum AccessibilityID: String {
    // MARK: - Screens

    case splashScreen = "SplashScreen"
    case songsView = "SongsView"
    case playerView = "PlayerView"
    case albumView = "AlbumView"
    case moreOptionsSheet = "MoreOptionsSheet"

    // MARK: - Songs View

    case recentlyPlayedSection = "RecentlyPlayedSection"
    case emptyStateText = "EmptyStateText"
    case noResultsView = "NoResultsView"

    // MARK: - Song Row

    case moreOptionsButton = "MoreOptionsButton"
    case nowPlayingIndicator = "NowPlayingIndicator"

    // MARK: - More Options Sheet

    case viewAlbumButton = "ViewAlbumButton"

    // MARK: - Player Controls

    case previousTrack = "Previous Track"
    case skipBackward = "Skip Backward"
    case playPause = "Play/Pause"
    case skipForward = "Skip Forward"
    case nextTrack = "Next Track"
    case repeatButton = "RepeatButton"
    case songProgress = "Song progress"
    case loadingSong = "Loading song"

    /// Dynamic identifier for a song row by ID.
    public static func songRow(id: Int) -> String {
        "SongRow-\(id)"
    }
}
