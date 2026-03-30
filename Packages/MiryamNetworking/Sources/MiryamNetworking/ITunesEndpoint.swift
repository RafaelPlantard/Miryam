import Foundation

/// iTunes API endpoints.
enum ITunesEndpoint {
    case search(query: String, limit: Int, offset: Int)
    case lookup(albumId: Int)

    private static let baseURL = "https://itunes.apple.com"

    var url: URL {
        switch self {
        case .search(let query, let limit, let offset):
            var components = URLComponents(string: "\(Self.baseURL)/search")!
            components.queryItems = [
                URLQueryItem(name: "term", value: query),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "entity", value: "song"),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset))
            ]
            return components.url!

        case .lookup(let albumId):
            var components = URLComponents(string: "\(Self.baseURL)/lookup")!
            components.queryItems = [
                URLQueryItem(name: "id", value: String(albumId)),
                URLQueryItem(name: "entity", value: "song")
            ]
            return components.url!
        }
    }
}
