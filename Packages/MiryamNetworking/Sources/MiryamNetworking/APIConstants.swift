import Foundation

/// iTunes API contract constants. Internal to the networking package.
enum APIConstants {
    /// Base URL for the iTunes Search API.
    static let baseURL = "https://itunes.apple.com"

    /// API path segments.
    enum Path {
        static let search = "/search"
        static let lookup = "/lookup"
    }

    /// Query parameter keys.
    enum QueryKey {
        static let term = "term"
        static let media = "media"
        static let entity = "entity"
        static let limit = "limit"
        static let offset = "offset"
        static let id = "id"
    }

    /// Query parameter values.
    enum QueryValue {
        static let mediaMusic = "music"
        static let entitySong = "song"
    }

    /// Wrapper type identifiers in API responses.
    enum WrapperType {
        static let track = "track"
    }

    /// HTTP status code constants.
    enum HTTP {
        static let successRange = 200 ... 299
        static let notFound = 404
    }
}
