import Foundation
import MiryamCore
import os

private let logger = Log.player

/// ViewModel for the Player screen.
@Observable
@MainActor
public final class PlayerViewModel {
    // MARK: - Published State

    public var playbackState = PlaybackState()
    public var currentSong: Song?
    public var isPlaying = false
    public var isBuffering = false
    public var error: AppError?
    public var repeatMode: RepeatMode = .off

    // MARK: - Private

    private let player: any PlayerProtocol
    private let cacheRepository: any CacheRepositoryProtocol
    @ObservationIgnored
    private nonisolated(unsafe) var stateTask: Task<Void, Never>?

    public init(
        player: any PlayerProtocol,
        cacheRepository: any CacheRepositoryProtocol
    ) {
        self.player = player
        self.cacheRepository = cacheRepository
        startObservingState()
    }

    /// Play a song. No-op if the same song is already playing.
    public func play(_ song: Song) async {
        if currentSong?.id == song.id, isPlaying {
            return
        }

        currentSong = song
        isBuffering = true
        error = nil

        logger.info("Playing: \(song.name) by \(song.artistName)")

        do {
            try await player.play(song)
            do {
                try await cacheRepository.markAsRecentlyPlayed(song)
            } catch {
                logger.warning("Failed to mark as recently played: \(error)")
            }
        } catch let appError as AppError {
            error = appError
            isPlaying = false
            logger.error("Playback failed: \(appError)")
        } catch {
            self.error = .playbackFailed(error.localizedDescription)
            isPlaying = false
            logger.error("Playback failed (unknown): \(error)")
        }
    }

    /// Toggle play/pause.
    public func togglePlayPause() async {
        if isPlaying {
            await player.pause()
        } else {
            await player.resume()
        }
    }

    /// Seek to position (0.0 to 1.0).
    public func seek(to progress: Double) async {
        await player.seek(to: progress)
    }

    /// Skip forward 15 seconds.
    public func skipForward() async {
        await player.skipForward(seconds: Constants.Player.skipInterval)
    }

    /// Skip backward 15 seconds.
    public func skipBackward() async {
        await player.skipBackward(seconds: Constants.Player.skipInterval)
    }

    /// Cycle repeat mode: off → all → one → off.
    public func toggleRepeat() async {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
        await player.setRepeatMode(repeatMode)
    }

    /// Stop playback.
    public func stop() async {
        await player.stop()
        currentSong = nil
    }

    // MARK: - Private

    private func startObservingState() {
        stateTask = Task { [weak self] in
            guard let self else { return }
            let stream = player.stateStream
            for await state in stream {
                guard !Task.isCancelled else { break }
                playbackState = state
                currentSong = state.currentSong
                switch state.status {
                case .playing:
                    isPlaying = true
                    isBuffering = false
                    error = nil
                case .paused:
                    isPlaying = false
                    isBuffering = false
                case let .failed(appError):
                    isPlaying = false
                    isBuffering = false
                    error = appError
                case .loading:
                    isBuffering = true
                case .idle:
                    isPlaying = false
                    isBuffering = false
                }
            }
        }
    }

    deinit {
        stateTask?.cancel()
    }
}
