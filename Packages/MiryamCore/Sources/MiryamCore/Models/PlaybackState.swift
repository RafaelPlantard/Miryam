import Foundation

/// Player state observable by ViewModels.
public struct PlaybackState: Sendable {
    public enum Status: Sendable, Equatable {
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

    /// Current time formatted as "m:ss" — computed once at init.
    public let formattedCurrentTime: String

    /// Remaining time formatted as "-m:ss" — computed once at init.
    public let formattedRemainingTime: String

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
        self.formattedCurrentTime = Self.format(time: currentTime)
        self.formattedRemainingTime = "-" + Self.format(time: max(duration - currentTime, 0))
    }

    private static func format(time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
