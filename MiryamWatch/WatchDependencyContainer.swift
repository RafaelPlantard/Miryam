import Foundation
import MiryamCore
import MiryamFeatures
import MiryamNetworking

@MainActor
final class WatchDependencyContainer {
    let playerViewModel: PlayerViewModel
    let sessionDelegate: WatchSessionDelegate
    private let remotePlayer: RemotePlayer
    private let songRepository: SongRepositoryProtocol

    init() {
        let player = RemotePlayer()
        self.remotePlayer = player
        self.sessionDelegate = WatchSessionDelegate(remotePlayer: player)
        let cache = WatchCacheRepository()
        let songRepo = SongRepository()
        self.songRepository = songRepo
        self.playerViewModel = PlayerViewModel(player: player, cacheRepository: cache)
    }

    func makeAlbumViewModel(album: Album) -> AlbumViewModel {
        AlbumViewModel(album: album, songRepository: songRepository)
    }
}

/// Minimal cache for watchOS — no SwiftData, just in-memory.
actor WatchCacheRepository: CacheRepositoryProtocol {
    private var played: [Song] = []

    func cacheSongs(_ songs: [Song], for query: String) async throws {}
    func cachedSongs(for query: String) async throws -> [Song] { [] }
    func markAsRecentlyPlayed(_ song: Song) async throws { played.append(song) }
    func recentlyPlayedSongs(limit: Int) async throws -> [Song] { Array(played.suffix(limit)) }
    func clearCache() async throws { played = [] }
}
