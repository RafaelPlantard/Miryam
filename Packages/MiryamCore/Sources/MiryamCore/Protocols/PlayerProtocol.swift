import Foundation

/// Contract for audio playback. Implemented by MiryamPlayer.
public protocol PlayerProtocol: Sendable {
    /// Start playing a song from its preview URL.
    func play(_ song: Song) async throws

    /// Pause current playback.
    func pause() async

    /// Resume paused playback.
    func resume() async

    /// Stop playback and reset.
    func stop() async

    /// Seek to a position (0.0 to 1.0).
    func seek(to progress: Double) async

    /// Skip forward by seconds.
    func skipForward(seconds: TimeInterval) async

    /// Skip backward by seconds.
    func skipBackward(seconds: TimeInterval) async

    /// Current playback state stream.
    var stateStream: AsyncStream<PlaybackState> { get }
}
