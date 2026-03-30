import Foundation
import MiryamCore

/// Remote implementation of SongRepositoryProtocol using iTunes API.
public actor SongRepository: SongRepositoryProtocol {
    private let httpClient: HTTPClient

    public init(httpClient: HTTPClient = HTTPClient()) {
        self.httpClient = httpClient
    }

    public func searchSongs(query: String, limit: Int, offset: Int) async throws -> SearchResult {
        let url = try ITunesEndpoint.search(query: query, limit: limit, offset: offset).makeURL()
        let response: ITunesSearchResponse = try await httpClient.fetch(url)

        let songs = response.results.compactMap { $0.toDomain() }
        return SearchResult(songs: songs, totalCount: response.resultCount)
    }

    public func fetchAlbumSongs(albumId: Int) async throws -> [Song] {
        let url = try ITunesEndpoint.lookup(albumId: albumId).makeURL()
        let response: ITunesSearchResponse = try await httpClient.fetch(url)

        return response.results.compactMap { $0.toDomain() }
            .sorted { $0.trackNumber < $1.trackNumber }
    }
}
