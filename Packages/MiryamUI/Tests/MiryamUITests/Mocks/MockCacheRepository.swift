import MiryamCore

/// A Sendable mock for CacheRepositoryProtocol.
final class MockCacheRepository: CacheRepositoryProtocol, @unchecked Sendable {
    var cachedSongsResult: [Song] = []
    var recentlyPlayedResult: [Song] = []

    func cacheSongs(_ songs: [Song], for query: String) async throws {}
    func cachedSongs(for query: String) async throws -> [Song] { cachedSongsResult }
    func markAsRecentlyPlayed(_ song: Song) async throws {}
    func recentlyPlayedSongs(limit: Int) async throws -> [Song] { recentlyPlayedResult }
    func clearCache() async throws {}
}
