import Foundation
import MiryamCore

/// Remote implementation of SongRepositoryProtocol using iTunes API.
public actor SongRepository: SongRepositoryProtocol {
    private let httpClient: HTTPClient

    public init(httpClient: HTTPClient = HTTPClient()) {
        self.httpClient = httpClient
    }

    public func searchSongs(query: String, limit: Int, offset: Int) async throws -> SearchResult {
        let url = ITunesEndpoint.search(query: query, limit: limit, offset: offset).url
        let response: ITunesSearchResponse

        do {
            response = try await httpClient.fetch(url)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkError(error.localizedDescription)
        }

        let songs = response.results.compactMap { $0.toDomain() }
        return SearchResult(songs: songs, totalCount: response.resultCount)
    }

    public func fetchAlbumSongs(albumId: Int) async throws -> [Song] {
        let url = ITunesEndpoint.lookup(albumId: albumId).url
        let response: ITunesSearchResponse

        do {
            response = try await httpClient.fetch(url)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkError(error.localizedDescription)
        }

        return response.results.compactMap { $0.toDomain() }
            .sorted { $0.trackNumber < $1.trackNumber }
    }
}
