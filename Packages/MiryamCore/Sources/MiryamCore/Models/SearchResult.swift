import Foundation

/// Paginated search results from the iTunes API.
public struct SearchResult: Sendable {
    public let songs: [Song]
    public let totalCount: Int

    public init(songs: [Song], totalCount: Int) {
        self.songs = songs
        self.totalCount = totalCount
    }
}
