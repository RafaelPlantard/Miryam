import MiryamCore
import MiryamFeatures

/// A Sendable mock for SongRepositoryProtocol used by snapshot tests.
/// Returns empty results by default — snapshots care about rendered state, not data fetching.
final class MockSongRepository: SongRepositoryProtocol, @unchecked Sendable {
    var searchResult = SearchResult(songs: [], totalCount: 0)
    var albumSongs: [Song] = []

    func searchSongs(query: String, limit: Int, offset: Int) async throws -> SearchResult {
        searchResult
    }

    func fetchAlbumSongs(albumId: Int) async throws -> [Song] {
        albumSongs
    }
}
