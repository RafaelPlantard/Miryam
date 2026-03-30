import Foundation
import MiryamCore

/// iTunes API endpoints.
enum ITunesEndpoint {
    case search(query: String, limit: Int, offset: Int)
    case lookup(albumId: Int)

    func makeURL() throws(AppError) -> URL {
        switch self {
        case let .search(query, limit, offset):
            guard var components = URLComponents(string: APIConstants.baseURL + APIConstants.Path.search) else {
                throw .networkError("Invalid base URL for search endpoint")
            }
            components.queryItems = [
                URLQueryItem(name: APIConstants.QueryKey.term, value: query),
                URLQueryItem(name: APIConstants.QueryKey.media, value: APIConstants.QueryValue.mediaMusic),
                URLQueryItem(name: APIConstants.QueryKey.entity, value: APIConstants.QueryValue.entitySong),
                URLQueryItem(name: APIConstants.QueryKey.limit, value: String(limit)),
                URLQueryItem(name: APIConstants.QueryKey.offset, value: String(offset)),
            ]
            guard let url = components.url else {
                throw .networkError("Failed to construct search URL")
            }
            return url

        case let .lookup(albumId):
            guard var components = URLComponents(string: APIConstants.baseURL + APIConstants.Path.lookup) else {
                throw .networkError("Invalid base URL for lookup endpoint")
            }
            components.queryItems = [
                URLQueryItem(name: APIConstants.QueryKey.id, value: String(albumId)),
                URLQueryItem(name: APIConstants.QueryKey.entity, value: APIConstants.QueryValue.entitySong),
            ]
            guard let url = components.url else {
                throw .networkError("Failed to construct lookup URL")
            }
            return url
        }
    }
}
