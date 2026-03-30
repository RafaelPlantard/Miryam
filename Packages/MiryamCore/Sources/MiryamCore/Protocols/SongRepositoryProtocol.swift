import Foundation

/// Contract for fetching songs from any data source.
/// Implemented by MiryamNetworking (remote) and MiryamPersistence (cache).
public protocol SongRepositoryProtocol: Sendable {
    /// Search songs by term with pagination.
    func searchSongs(query: String, limit: Int, offset: Int) async throws -> SearchResult

    /// Fetch all songs in an album.
    func fetchAlbumSongs(albumId: Int) async throws -> [Song]
}
