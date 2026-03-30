@preconcurrency import AVFoundation
import Foundation
import MiryamCore

/// AVFoundation-based audio player actor implementing ``PlayerProtocol``.
///
/// Plays 30-second iTunes preview clips via ``AVPlayer`` and publishes
/// ``PlaybackState`` updates through an ``AsyncStream``.
public actor AudioPlayer: PlayerProtocol {
    // MARK: - Properties

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var currentSong: Song?
    private var continuation: AsyncStream<PlaybackState>.Continuation?
    private var endObservation: (any NSObjectProtocol)?

    private let _stateStream: AsyncStream<PlaybackState>

    // MARK: - PlayerProtocol

    public nonisolated var stateStream: AsyncStream<PlaybackState> {
        _stateStream
    }

    // MARK: - Init

    public init() {
        let (stream, continuation) = AsyncStream<PlaybackState>.makeStream()
        self._stateStream = stream
        self.continuation = continuation
    }

    // MARK: - Playback

    public func play(_ song: Song) async throws {
        guard let previewURL = song.previewURL else {
            throw AppError.playbackFailed("No preview URL available")
        }

        // Clean up any previous playback
        await stop()

        currentSong = song
        emitState(.init(status: .loading, currentSong: song))

        #if os(iOS) || os(watchOS) || os(visionOS)
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                throw AppError.playbackFailed(
                    "Audio session setup failed: \(error.localizedDescription)"
                )
            }
        #endif

        let playerItem = AVPlayerItem(url: previewURL)
        let avPlayer = AVPlayer(playerItem: playerItem)
        player = avPlayer

        addTimeObserver(to: avPlayer)
        observePlaybackEnd(of: playerItem)

        avPlayer.play()
        emitState(.init(status: .playing, currentSong: song))
    }

    public func pause() async {
        player?.pause()
        if let song = currentSong {
            emitState(makeCurrentState(status: .paused, song: song))
        }
    }

    public func resume() async {
        player?.play()
        if let song = currentSong {
            emitState(makeCurrentState(status: .playing, song: song))
        }
    }

    public func stop() async {
        removeTimeObserver()
        removeEndObservation()
        player?.pause()
        player = nil
        currentSong = nil
        emitState(.init(status: .idle))
    }

    public func seek(to progress: Double) async {
        guard let player, let item = player.currentItem else { return }
        let duration = item.duration.seconds
        guard duration.isFinite, duration > 0 else { return }

        let targetTime = CMTime(
            seconds: duration * progress.clamped(to: 0 ... 1),
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )
        await player.seek(to: targetTime)
    }

    public func skipForward(seconds: TimeInterval = 10) async {
        guard let player else { return }
        let currentTime = player.currentTime().seconds
        let duration = player.currentItem?.duration.seconds ?? 0
        guard duration.isFinite, duration > 0 else { return }

        let newTime = min(currentTime + seconds, duration)
        let target = CMTime(
            seconds: newTime,
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )
        await player.seek(to: target)
    }

    public func skipBackward(seconds: TimeInterval = 10) async {
        guard let player else { return }
        let currentTime = player.currentTime().seconds

        let newTime = max(currentTime - seconds, 0)
        let target = CMTime(
            seconds: newTime,
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )
        await player.seek(to: target)
    }

    // MARK: - Observers

    private func addTimeObserver(to avPlayer: AVPlayer) {
        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = avPlayer.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            Task {
                await self.handleTimeUpdate(time)
            }
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver, let player {
            player.removeTimeObserver(observer)
        }
        timeObserver = nil
    }

    private func observePlaybackEnd(of playerItem: AVPlayerItem) {
        endObservation = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task {
                await self.handlePlaybackEnd()
            }
        }
    }

    private func removeEndObservation() {
        if let token = endObservation {
            NotificationCenter.default.removeObserver(token)
        }
        endObservation = nil
    }

    // MARK: - State Helpers

    private func handleTimeUpdate(_ time: CMTime) {
        guard let song = currentSong, let item = player?.currentItem else { return }
        let currentTime = time.seconds
        let duration = item.duration.seconds

        guard duration.isFinite, duration > 0 else { return }

        emitState(PlaybackState(
            status: .playing,
            currentSong: song,
            currentTime: currentTime,
            duration: duration,
            progress: currentTime / duration
        ))
    }

    private func handlePlaybackEnd() {
        guard let song = currentSong else { return }
        let duration = player?.currentItem?.duration.seconds ?? 0

        emitState(PlaybackState(
            status: .paused,
            currentSong: song,
            currentTime: duration.isFinite ? duration : 0,
            duration: duration.isFinite ? duration : 0,
            progress: 1.0
        ))
    }

    private func makeCurrentState(status: PlaybackState.Status, song: Song) -> PlaybackState {
        let currentTime = player?.currentTime().seconds ?? 0
        let duration = player?.currentItem?.duration.seconds ?? 0
        let safeCurrent = currentTime.isFinite ? currentTime : 0
        let safeDuration = duration.isFinite ? duration : 0
        let progress = safeDuration > 0 ? safeCurrent / safeDuration : 0

        return PlaybackState(
            status: status,
            currentSong: song,
            currentTime: safeCurrent,
            duration: safeDuration,
            progress: progress
        )
    }

    private func emitState(_ state: PlaybackState) {
        continuation?.yield(state)
    }

    // MARK: - Deinit

    deinit {
        continuation?.finish()
    }
}

// MARK: - Comparable Clamping

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
