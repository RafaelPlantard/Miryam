import Foundation

/// Tracks pagination state for API requests.
public struct Pagination: Sendable {
    public let limit: Int
    public private(set) var offset: Int
    public private(set) var hasMorePages: Bool

    public init(limit: Int = Constants.Search.pageLimit) {
        self.limit = limit
        self.offset = 0
        self.hasMorePages = true
    }

    /// Advance to next page based on result count.
    public mutating func advance(resultCount: Int) {
        offset += resultCount
        hasMorePages = resultCount >= limit
    }

    /// Reset to first page.
    public mutating func reset() {
        offset = 0
        hasMorePages = true
    }
}
