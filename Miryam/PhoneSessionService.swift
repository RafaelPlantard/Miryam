import Foundation
import MiryamCore
@preconcurrency import WatchConnectivity

private let logger = Log.phoneSession

/// Bridges iPhone playback state to the paired Apple Watch via WatchConnectivity.
///
/// Observes the player's ``AsyncStream`` and pushes each ``PlaybackState``
/// to the Watch through `updateApplicationContext`. Incoming messages from
/// the Watch are forwarded as commands to the player.
final class PhoneSessionService: NSObject, WCSessionDelegate, @unchecked Sendable {
    private let player: any PlayerProtocol

    init(player: any PlayerProtocol) {
        self.player = player
        super.init()

        guard WCSession.isSupported() else {
            logger.info("WCSession not supported on this device")
            return
        }
        WCSession.default.delegate = self
        WCSession.default.activate()
        logger.info("WCSession activated on iPhone")
    }

    // MARK: - State Sync (iPhone → Watch)

    /// Sends a playback state update to the paired Apple Watch.
    /// Called by ``PlayerViewModel.onStateChanged`` to avoid competing
    /// for the unicast ``AsyncStream`` (which caused missed UI updates).
    static func sendStateToWatch(_ state: PlaybackState) {
        guard WCSession.default.activationState == .activated,
              WCSession.default.isPaired,
              WCSession.default.isWatchAppInstalled
        else { return }

        let message = PlaybackStateMessage(from: state)
        do {
            let data = try JSONEncoder().encode(message)
            try WCSession.default.updateApplicationContext(["playbackState": data])
        } catch {
            logger.error("Failed to send state to Watch: \(error)")
        }
    }

    // MARK: - Command Handling (Watch → iPhone)

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        let parsed = Self.parseCommand(from: message)
        guard let parsed else {
            replyHandler(["error": "missing command"])
            return
        }
        let player = player
        nonisolated(unsafe) let reply = replyHandler
        Task {
            await Self.executeCommand(parsed, player: player)
            reply(["status": "ok"])
        }
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        guard let parsed = Self.parseCommand(from: message) else { return }
        let player = player
        Task {
            await Self.executeCommand(parsed, player: player)
        }
    }

    // MARK: - Command Parsing

    private enum PlayerCommand: Sendable {
        case play(Song)
        case pause
        case resume
        case stop
        case seek(progress: Double)
        case skipForward(seconds: TimeInterval)
        case skipBackward(seconds: TimeInterval)
        case setRepeatMode(RepeatMode)
    }

    private static func parseCommand(from message: [String: Any]) -> PlayerCommand? {
        guard let command = message["command"] as? String else { return nil }
        logger.debug("Received command from Watch: \(command)")

        switch command {
        case "play": return parseSong(from: message).map { .play($0) }
        case "pause": return .pause
        case "resume": return .resume
        case "stop": return .stop
        case "seek": return (message["progress"] as? Double).map { .seek(progress: $0) }
        case "skipForward": return .skipForward(seconds: skipSeconds(from: message))
        case "skipBackward": return .skipBackward(seconds: skipSeconds(from: message))
        case "setRepeatMode": return parseRepeatMode(from: message).map { .setRepeatMode($0) }
        default:
            logger.warning("Unknown command from Watch: \(command)")
            return nil
        }
    }

    private static func parseSong(from message: [String: Any]) -> Song? {
        guard let data = message["song"] as? Data else { return nil }
        return try? JSONDecoder().decode(Song.self, from: data)
    }

    private static func skipSeconds(from message: [String: Any]) -> TimeInterval {
        message["seconds"] as? TimeInterval ?? Constants.Player.skipInterval
    }

    private static func parseRepeatMode(from message: [String: Any]) -> RepeatMode? {
        guard let rawValue = message["mode"] as? String else { return nil }
        return RepeatMode(rawValue: rawValue)
    }

    private static func executeCommand(_ command: PlayerCommand, player: any PlayerProtocol) async {
        switch command {
        case let .play(song): try? await player.play(song)
        case .pause: await player.pause()
        case .resume: await player.resume()
        case .stop: await player.stop()
        case let .seek(progress): await player.seek(to: progress)
        case let .skipForward(seconds): await player.skipForward(seconds: seconds)
        case let .skipBackward(seconds): await player.skipBackward(seconds: seconds)
        case let .setRepeatMode(mode): await player.setRepeatMode(mode)
        }
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        if let error {
            logger.error("WCSession activation failed: \(error)")
        } else {
            logger.info("WCSession activation completed: \(activationState.rawValue)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        logger.debug("WCSession became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        logger.debug("WCSession deactivated, reactivating")
        session.activate()
    }
}
