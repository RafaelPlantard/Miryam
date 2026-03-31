#if canImport(MediaPlayer)
    import Foundation
    import MediaPlayer
    import MiryamCore

    #if os(macOS)
        import AppKit
    #else
        import UIKit
    #endif

    struct RemoteCommandCallbacks: Sendable {
        let onPlay: @Sendable () async -> Void
        let onPause: @Sendable () async -> Void
        let onTogglePlayPause: @Sendable () async -> Void
        let onSkipForward: @Sendable () async -> Void
        let onSkipBackward: @Sendable () async -> Void
        let onNextTrack: @Sendable () async -> Void
        let onPreviousTrack: @Sendable () async -> Void
        let onSeek: @Sendable (Double) async -> Void
    }

    /// Publishes playback metadata to the system Now Playing info center
    /// and registers remote command handlers (lock screen, Control Center, CarPlay).
    actor NowPlayingService {
        private var commandsRegistered = false
        private var callbacks: RemoteCommandCallbacks?

        func setCallbacks(_ callbacks: RemoteCommandCallbacks) {
            self.callbacks = callbacks
        }

        // MARK: - Metadata

        func updateNowPlaying(song: Song, currentTime: TimeInterval, duration: TimeInterval, isPlaying: Bool) {
            var info = [String: Any]()
            info[MPMediaItemPropertyTitle] = song.name
            info[MPMediaItemPropertyArtist] = song.artistName
            info[MPMediaItemPropertyAlbumTitle] = song.albumName
            info[MPMediaItemPropertyPlaybackDuration] = duration
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

            if let cachedArtwork {
                info[MPMediaItemPropertyArtwork] = cachedArtwork
            }

            MPNowPlayingInfoCenter.default().nowPlayingInfo = info

            if !commandsRegistered {
                registerRemoteCommands()
            }

            loadArtwork(for: song)
        }

        func updatePlaybackRate(_ rate: Double, elapsed: TimeInterval) {
            guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
            info[MPNowPlayingInfoPropertyPlaybackRate] = rate
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsed
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }

        func clearNowPlaying() {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            cachedArtwork = nil
            lastArtworkSongId = nil
        }

        // MARK: - Remote Commands

        private func registerRemoteCommands() {
            let center = MPRemoteCommandCenter.shared()

            center.playCommand.isEnabled = true
            center.playCommand.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                Task { await self.callbacks?.onPlay() }
                return .success
            }

            center.pauseCommand.isEnabled = true
            center.pauseCommand.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                Task { await self.callbacks?.onPause() }
                return .success
            }

            center.togglePlayPauseCommand.isEnabled = true
            center.togglePlayPauseCommand.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                Task { await self.callbacks?.onTogglePlayPause() }
                return .success
            }

            center.skipForwardCommand.isEnabled = true
            center.skipForwardCommand.preferredIntervals = [NSNumber(value: Constants.Player.skipInterval)]
            center.skipForwardCommand.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                Task { await self.callbacks?.onSkipForward() }
                return .success
            }

            center.skipBackwardCommand.isEnabled = true
            center.skipBackwardCommand.preferredIntervals = [NSNumber(value: Constants.Player.skipInterval)]
            center.skipBackwardCommand.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                Task { await self.callbacks?.onSkipBackward() }
                return .success
            }

            center.nextTrackCommand.isEnabled = true
            center.nextTrackCommand.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                Task { await self.callbacks?.onNextTrack() }
                return .success
            }

            center.previousTrackCommand.isEnabled = true
            center.previousTrackCommand.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                Task { await self.callbacks?.onPreviousTrack() }
                return .success
            }

            center.changePlaybackPositionCommand.isEnabled = true
            center.changePlaybackPositionCommand.addTarget { [weak self] event in
                guard let self,
                      let positionEvent = event as? MPChangePlaybackPositionCommandEvent
                else { return .commandFailed }
                let info = MPNowPlayingInfoCenter.default().nowPlayingInfo
                let duration = (info?[MPMediaItemPropertyPlaybackDuration] as? TimeInterval) ?? 1
                let progress = duration > 0 ? positionEvent.positionTime / duration : 0
                Task { await self.callbacks?.onSeek(progress) }
                return .success
            }

            commandsRegistered = true
        }

        // MARK: - Artwork

        private var lastArtworkSongId: Int?
        private var cachedArtwork: MPMediaItemArtwork?

        private func loadArtwork(for song: Song) {
            guard song.id != lastArtworkSongId else { return }
            lastArtworkSongId = song.id
            cachedArtwork = nil

            guard let url = song.artworkURL(size: 600) else { return }
            let songId = song.id

            Task.detached { [weak self] in
                guard let (data, _) = try? await URLSession.shared.data(from: url) else { return }
                await self?.applyArtwork(imageData: data, songId: songId)
            }
        }

        private func applyArtwork(imageData: Data, songId: Int) {
            guard songId == lastArtworkSongId,
                  let image = Self.makeImage(from: imageData)
            else { return }

            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            cachedArtwork = artwork

            // MPNowPlayingInfoCenter must be accessed on the main thread
            nonisolated(unsafe) let artworkRef = artwork
            Task { @MainActor in
                guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
                info[MPMediaItemPropertyArtwork] = artworkRef
                MPNowPlayingInfoCenter.default().nowPlayingInfo = info
            }
        }

        #if os(macOS)
            private static func makeImage(from data: Data) -> NSImage? {
                NSImage(data: data)
            }
        #else
            private static func makeImage(from data: Data) -> UIImage? {
                UIImage(data: data)
            }
        #endif
    }
#endif
