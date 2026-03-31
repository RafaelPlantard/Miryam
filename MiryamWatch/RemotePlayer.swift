import Foundation
import MiryamCore
import WatchConnectivity
import os

private let logger = Logger(subsystem: "io.swift-yah.miryam.watchkitapp", category: "RemotePlayer")

/// A ``PlayerProtocol`` implementation that proxies commands to the paired
/// iPhone via WatchConnectivity and receives playback state updates.
///
/// Instead of playing audio locally, every command is sent as a message
/// to the iPhone's ``PhoneSessionService``, which forwards it to the
/// real ``AudioPlayer``.
public actor RemotePlayer: PlayerProtocol {
    private var continuation: AsyncStream<PlaybackState>.Continuation?
    private let _stateStream: AsyncStream<PlaybackState>

    public nonisolated var stateStream: AsyncStream<PlaybackState> {
        _stateStream
    }

    public init() {
        let (stream, continuation) = AsyncStream<PlaybackState>.makeStream()
        self._stateStream = stream
        self.continuation = continuation
    }

    // MARK: - PlayerProtocol Commands

    public func play(_ song: Song) async throws {
        guard let songData = try? JSONEncoder().encode(song) else {
            throw AppError.playbackFailed("Failed to encode song for Watch transfer")
        }
        sendCommand(["command": "play", "song": songData])
    }

    public func pause() async {
        sendCommand(["command": "pause"])
    }

    public func resume() async {
        sendCommand(["command": "resume"])
    }

    public func stop() async {
        sendCommand(["command": "stop"])
    }

    public func seek(to progress: Double) async {
        sendCommand(["command": "seek", "progress": progress])
    }

    public func skipForward(seconds: TimeInterval) async {
        sendCommand(["command": "skipForward", "seconds": seconds])
    }

    public func skipBackward(seconds: TimeInterval) async {
        sendCommand(["command": "skipBackward", "seconds": seconds])
    }

    public func setRepeatMode(_ mode: RepeatMode) async {
        sendCommand(["command": "setRepeatMode", "mode": mode.rawValue])
    }

    // MARK: - State Reception

    /// Called by ``WatchSessionDelegate`` when new playback state arrives from iPhone.
    public func handleReceivedState(_ data: Data) {
        guard let message = try? JSONDecoder().decode(PlaybackStateMessage.self, from: data) else {
            logger.error("Failed to decode PlaybackStateMessage from iPhone")
            return
        }
        let state = message.toPlaybackState()
        continuation?.yield(state)
    }

    /// Called by ``WatchSessionDelegate`` when the initial application context is available.
    public func handleApplicationContext(_ context: [String: Any]) {
        guard let data = context["playbackState"] as? Data else { return }
        handleReceivedState(data)
    }

    // MARK: - Command Sending

    private nonisolated func sendCommand(_ message: [String: Any]) {
        guard WCSession.default.isReachable else {
            logger.debug("iPhone not reachable, command dropped")
            return
        }
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            logger.error("Failed to send command to iPhone: \(error)")
        }
    }

    deinit {
        continuation?.finish()
    }
}
