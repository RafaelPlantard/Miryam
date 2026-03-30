import Foundation

/// Contract for local song caching and recently played tracking.
/// Implemented by MiryamPersistence.
public protocol CacheRepositoryProtocol: Sendable {
    /// Cache songs for offline access, associated with a search query.
    func cacheSongs(_ songs: [Song], for query: String) async throws

    /// Retrieve cached songs for a search query.
    func cachedSongs(for query: String) async throws -> [Song]

    /// Mark a song as recently played.
    func markAsRecentlyPlayed(_ song: Song) async throws

    /// Get recently played songs (most recent first).
    func recentlyPlayedSongs(limit: Int) async throws -> [Song]

    /// Clear all cached data.
    func clearCache() async throws
}
