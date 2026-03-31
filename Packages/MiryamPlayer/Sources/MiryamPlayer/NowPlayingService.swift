#if canImport(MediaPlayer)
    import Foundation
    import MediaPlayer
    import MiryamCore

    #if os(macOS)
        import AppKit
    #else
        import UIKit
    #endif

    /// Publishes playback metadata to the system Now Playing info center
    /// and registers remote command handlers (lock screen, Control Center, CarPlay).
    actor NowPlayingService {
        private var commandsRegistered = false

        // Callbacks wired by AudioPlayer
        var onPlay: (@Sendable () async -> Void)?
        var onPause: (@Sendable () async -> Void)?
        var onTogglePlayPause: (@Sendable () async -> Void)?
        var onSkipForward: (@Sendable () async -> Void)?
        var onSkipBackward: (@Sendable () async -> Void)?
        var onSeek: (@Sendable (Double) async -> Void)?

        func setCallbacks(
            onPlay: @escaping @Sendable () async -> Void,
            onPause: @escaping @Sendable () async -> Void,
            onTogglePlayPause: @escaping @Sendable () async -> Void,
            onSkipForward: @escaping @Sendable () async -> Void,
            onSkipBackward: @escaping @Sendable () async -> Void,
            onSeek: @escaping @Sendable (Double) async -> Void
        ) {
            self.onPlay = onPlay
            self.onPause = onPause
            self.onTogglePlayPause = onTogglePlayPause
            self.onSkipForward = onSkipForward
            self.onSkipBackward = onSkipBackward
            self.onSeek = onSeek
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
        }

        // MARK: - Remote Commands

        private func registerRemoteCommands() {
            let center = MPRemoteCommandCenter.shared()

            center.playCommand.isEnabled = true
            center.playCommand.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                Task { await self.onPlay?() }
                return .success
            }

            center.pauseCommand.isEnabled = true
            center.pauseCommand.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                Task { await self.onPause?() }
                return .success
            }

            center.togglePlayPauseCommand.isEnabled = true
            center.togglePlayPauseCommand.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                Task { await self.onTogglePlayPause?() }
                return .success
            }

            center.skipForwardCommand.isEnabled = true
            center.skipForwardCommand.preferredIntervals = [NSNumber(value: Constants.Player.skipInterval)]
            center.skipForwardCommand.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                Task { await self.onSkipForward?() }
                return .success
            }

            center.skipBackwardCommand.isEnabled = true
            center.skipBackwardCommand.preferredIntervals = [NSNumber(value: Constants.Player.skipInterval)]
            center.skipBackwardCommand.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                Task { await self.onSkipBackward?() }
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
                Task { await self.onSeek?(progress) }
                return .success
            }

            commandsRegistered = true
        }

        // MARK: - Artwork

        private var lastArtworkSongId: Int?

        private func loadArtwork(for song: Song) {
            guard song.id != lastArtworkSongId else { return }
            lastArtworkSongId = song.id

            guard let url = song.artworkURL(size: 600) else { return }

            Task.detached { [weak self] in
                guard let data = try? Data(contentsOf: url),
                      let image = Self.makeImage(from: data)
                else { return }

                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }

                await MainActor.run {
                    guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
                    info[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                }

                await self?.setLastArtworkSongId(song.id)
            }
        }

        private func setLastArtworkSongId(_ id: Int) {
            lastArtworkSongId = id
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
