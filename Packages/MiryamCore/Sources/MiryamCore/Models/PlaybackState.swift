import Foundation

/// Player state observable by ViewModels.
public struct PlaybackState: Sendable {
    public enum Status: Sendable {
        case idle
        case loading
        case playing
        case paused
        case failed(AppError)
    }

    public var status: Status
    public var currentSong: Song?
    public var currentTime: TimeInterval
    public var duration: TimeInterval
    public var progress: Double

    public init(
        status: Status = .idle,
        currentSong: Song? = nil,
        currentTime: TimeInterval = 0,
        duration: TimeInterval = 0,
        progress: Double = 0
    ) {
        self.status = status
        self.currentSong = currentSong
        self.currentTime = currentTime
        self.duration = duration
        self.progress = progress
    }

    /// Current time formatted as "m:ss"
    public var formattedCurrentTime: String {
        Self.format(time: currentTime)
    }

    /// Remaining time formatted as "-m:ss"
    public var formattedRemainingTime: String {
        let remaining = max(duration - currentTime, 0)
        return "-" + Self.format(time: remaining)
    }

    private static func format(time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
