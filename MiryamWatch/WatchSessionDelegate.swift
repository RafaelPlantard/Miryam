import Foundation
import WatchConnectivity
import os

private let logger = Logger(subsystem: "io.swift-yah.miryam.watchkitapp", category: "WatchSession")

/// WCSession delegate for the Watch side.
///
/// Receives application-context updates from the iPhone containing
/// encoded ``PlaybackStateMessage`` data and forwards them to ``RemotePlayer``.
final class WatchSessionDelegate: NSObject, WCSessionDelegate, @unchecked Sendable {
    private let remotePlayer: RemotePlayer

    init(remotePlayer: RemotePlayer) {
        self.remotePlayer = remotePlayer
        super.init()

        guard WCSession.isSupported() else {
            logger.info("WCSession not supported")
            return
        }
        WCSession.default.delegate = self
        WCSession.default.activate()
        logger.info("WCSession activated on Watch")
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
            // Pick up any existing application context from iPhone
            let player = remotePlayer
            guard let data = session.receivedApplicationContext["playbackState"] as? Data else { return }
            Task { await player.handleReceivedState(data) }
        }
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        let player = remotePlayer
        guard let data = applicationContext["playbackState"] as? Data else { return }
        Task { await player.handleReceivedState(data) }
    }
}
