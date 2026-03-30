import Foundation
import MiryamCore

/// ViewModel for the Player screen.
@Observable
@MainActor
public final class PlayerViewModel {
    // MARK: - Published State
    public var playbackState = PlaybackState()
    public var currentSong: Song?
    public var isPlaying = false
    public var error: AppError?

    // MARK: - Private
    private let player: any PlayerProtocol
    private let cacheRepository: any CacheRepositoryProtocol
    @ObservationIgnored
    nonisolated(unsafe) private var stateTask: Task<Void, Never>?

    public init(
        player: any PlayerProtocol,
        cacheRepository: any CacheRepositoryProtocol
    ) {
        self.player = player
        self.cacheRepository = cacheRepository
        startObservingState()
    }

    /// Play a song.
    public func play(_ song: Song) async {
        currentSong = song
        error = nil

        do {
            try await player.play(song)
            try? await cacheRepository.markAsRecentlyPlayed(song)
        } catch let appError as AppError {
            error = appError
            isPlaying = false
        } catch {
            self.error = .playbackFailed(error.localizedDescription)
            isPlaying = false
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
        await player.skipForward(seconds: 15)
    }

    /// Skip backward 15 seconds.
    public func skipBackward() async {
        await player.skipBackward(seconds: 15)
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
            let stream = self.player.stateStream
            for await state in stream {
                guard !Task.isCancelled else { break }
                self.playbackState = state
                self.currentSong = state.currentSong
                switch state.status {
                case .playing:
                    self.isPlaying = true
                    self.error = nil
                case .paused:
                    self.isPlaying = false
                case .failed(let appError):
                    self.isPlaying = false
                    self.error = appError
                case .idle, .loading:
                    break
                }
            }
        }
    }

    deinit {
        stateTask?.cancel()
    }
}
