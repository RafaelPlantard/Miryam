import Foundation
import MiryamCore
@preconcurrency import WatchConnectivity
import os

private let logger = Logger(subsystem: "io.swift-yah.miryam", category: "PhoneSession")

/// Bridges iPhone playback state to the paired Apple Watch via WatchConnectivity.
///
/// Observes the player's ``AsyncStream`` and pushes each ``PlaybackState``
/// to the Watch through `updateApplicationContext`. Incoming messages from
/// the Watch are forwarded as commands to the player.
final class PhoneSessionService: NSObject, WCSessionDelegate, @unchecked Sendable {
    private let player: any PlayerProtocol
    private var observeTask: Task<Void, Never>?

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

    func startObserving() {
        observeTask?.cancel()
        let player = player
        observeTask = Task {
            for await state in player.stateStream {
                guard !Task.isCancelled else { break }
                Self.sendStateToWatch(state)
            }
        }
    }

    // MARK: - State Sync (iPhone → Watch)

    private static func sendStateToWatch(_ state: PlaybackState) {
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
        case "play":
            guard let songData = message["song"] as? Data,
                  let song = try? JSONDecoder().decode(Song.self, from: songData)
            else { return nil }
            return .play(song)
        case "pause": return .pause
        case "resume": return .resume
        case "stop": return .stop
        case "seek":
            guard let progress = message["progress"] as? Double else { return nil }
            return .seek(progress: progress)
        case "skipForward":
            let seconds = message["seconds"] as? TimeInterval ?? Constants.Player.skipInterval
            return .skipForward(seconds: seconds)
        case "skipBackward":
            let seconds = message["seconds"] as? TimeInterval ?? Constants.Player.skipInterval
            return .skipBackward(seconds: seconds)
        case "setRepeatMode":
            guard let rawValue = message["mode"] as? String,
                  let mode = RepeatMode(rawValue: rawValue)
            else { return nil }
            return .setRepeatMode(mode)
        default:
            logger.warning("Unknown command from Watch: \(command)")
            return nil
        }
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

    deinit {
        observeTask?.cancel()
    }
}
