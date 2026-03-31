import Foundation

/// Codable DTO for transferring playback state over WatchConnectivity.
public struct PlaybackStateMessage: Codable, Sendable {
    public let status: String
    public let song: Song?
    public let currentTime: TimeInterval
    public let duration: TimeInterval
    public let progress: Double
    public let errorMessage: String?

    public init(
        status: String,
        song: Song?,
        currentTime: TimeInterval,
        duration: TimeInterval,
        progress: Double,
        errorMessage: String?
    ) {
        self.status = status
        self.song = song
        self.currentTime = currentTime
        self.duration = duration
        self.progress = progress
        self.errorMessage = errorMessage
    }

    public init(from state: PlaybackState) {
        let statusString: String
        var errorMsg: String?
        switch state.status {
        case .idle: statusString = "idle"
        case .loading: statusString = "loading"
        case .playing: statusString = "playing"
        case .paused: statusString = "paused"
        case let .failed(error):
            statusString = "failed"
            errorMsg = error.userMessage
        }
        self.status = statusString
        self.song = state.currentSong
        self.currentTime = state.currentTime
        self.duration = state.duration
        self.progress = state.progress
        self.errorMessage = errorMsg
    }

    public func toPlaybackState() -> PlaybackState {
        let playbackStatus: PlaybackState.Status = switch status {
        case "loading": .loading
        case "playing": .playing
        case "paused": .paused
        case "failed": .failed(.playbackFailed(errorMessage ?? "Unknown error"))
        default: .idle
        }
        return PlaybackState(
            status: playbackStatus,
            currentSong: song,
            currentTime: currentTime,
            duration: duration,
            progress: progress
        )
    }
}
