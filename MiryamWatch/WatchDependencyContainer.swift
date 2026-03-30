import Foundation
import MiryamCore
import MiryamPlayer
import MiryamFeatures

@MainActor
final class WatchDependencyContainer {
    let playerViewModel: PlayerViewModel

    init() {
        let player = AudioPlayer()
        let cache = WatchCacheRepository()
        self.playerViewModel = PlayerViewModel(player: player, cacheRepository: cache)
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
