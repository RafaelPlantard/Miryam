import Foundation

/// iTunes API endpoints.
enum ITunesEndpoint {
    case search(query: String, limit: Int, offset: Int)
    case lookup(albumId: Int)

    var url: URL {
        switch self {
        case let .search(query, limit, offset):
            var components = URLComponents(string: APIConstants.baseURL + APIConstants.Path.search)!
            components.queryItems = [
                URLQueryItem(name: APIConstants.QueryKey.term, value: query),
                URLQueryItem(name: APIConstants.QueryKey.media, value: APIConstants.QueryValue.mediaMusic),
                URLQueryItem(name: APIConstants.QueryKey.entity, value: APIConstants.QueryValue.entitySong),
                URLQueryItem(name: APIConstants.QueryKey.limit, value: String(limit)),
                URLQueryItem(name: APIConstants.QueryKey.offset, value: String(offset)),
            ]
            return components.url!

        case let .lookup(albumId):
            var components = URLComponents(string: APIConstants.baseURL + APIConstants.Path.lookup)!
            components.queryItems = [
                URLQueryItem(name: APIConstants.QueryKey.id, value: String(albumId)),
                URLQueryItem(name: APIConstants.QueryKey.entity, value: APIConstants.QueryValue.entitySong),
            ]
            return components.url!
        }
    }
}
