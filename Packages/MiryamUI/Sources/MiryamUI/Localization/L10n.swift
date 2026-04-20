import Foundation

public enum L10n {
    public static let all: LocalizedStringResource = "All"
    public static let appName: LocalizedStringResource = "Miryam"
    public static let closePlayer: LocalizedStringResource = "Close player"
    public static let doubleTapForAdditionalActions: LocalizedStringResource = "Double tap for additional actions"
    public static let doubleTapToPlay: LocalizedStringResource = "Double tap to play"
    public static let dragToSeekWithinTheSong: LocalizedStringResource = "Drag to seek within the song"
    public static let loading: LocalizedStringResource = "Loading..."
    public static let loadingSong: LocalizedStringResource = "Loading song"
    public static let moreOptions: LocalizedStringResource = "More options"
    public static let nextTrack: LocalizedStringResource = "Next track"
    public static let noResultsFound: LocalizedStringResource = "No results found"
    public static let notPlaying: LocalizedStringResource = "Not Playing"
    public static let off: LocalizedStringResource = "Off"
    public static let one: LocalizedStringResource = "One"
    public static let pause: LocalizedStringResource = "Pause"
    public static let paused: LocalizedStringResource = "Paused"
    public static let play: LocalizedStringResource = "Play"
    public static let playbackProgress: LocalizedStringResource = "Playback progress"
    public static let playing: LocalizedStringResource = "Playing"
    public static let previousTrack: LocalizedStringResource = "Previous track"
    public static let queue: LocalizedStringResource = "Queue"
    public static let recentlyPlayed: LocalizedStringResource = "Recently Played"
    public static let repeatLabel: LocalizedStringResource = "Repeat"
    public static let search: LocalizedStringResource = "Search"
    public static let searchForSongs: LocalizedStringResource = "Search for songs"
    public static let skipBackward5: LocalizedStringResource = "Skip backward 5 seconds"
    public static let skipForward5: LocalizedStringResource = "Skip forward 5 seconds"
    public static let songs: LocalizedStringResource = "Songs"
    public static let tryAgain: LocalizedStringResource = "Try Again"
    public static let unableToLoad: LocalizedStringResource = "Unable to Load"
    public static let viewAlbum: LocalizedStringResource = "View album"

    public static let metadataSeparator = "·"

    public static func compactPlayerTitle(songName: String, artistName: String) -> String {
        "\(songName) — \(artistName)"
    }

    public static func moreOptions(for songName: String) -> String {
        String(localized: "More options for \(songName)")
    }

    public static func percentage(_ value: Int) -> String {
        String(localized: "\(value)%")
    }

    public static func songArtistLabel(songName: String, artistName: String) -> String {
        String(localized: "\(songName) by \(artistName)")
    }

    public static func string(_ resource: LocalizedStringResource) -> String {
        String(localized: resource)
    }

    public static func trackCount(_ count: Int) -> String {
        String(localized: "\(count) tracks")
    }

    public static func viewAlbum(for albumName: String) -> String {
        String(localized: "View album \(albumName)")
    }
}
