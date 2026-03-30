import MiryamCore

/// A Sendable mock for PlayerProtocol.
final class MockPlayer: PlayerProtocol, @unchecked Sendable {
    var stateStream: AsyncStream<PlaybackState> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }

    func play(_ song: Song) async throws {}
    func pause() async {}
    func resume() async {}
    func stop() async {}
    func seek(to progress: Double) async {}
    func skipForward(seconds: TimeInterval) async {}
    func skipBackward(seconds: TimeInterval) async {}
}
