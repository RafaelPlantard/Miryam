import Foundation

/// An album from the iTunes catalog.
public struct Album: Sendable, Identifiable, Hashable, Codable {
    public let id: Int
    public let name: String
    public let artistName: String
    public let artworkURL: URL?
    public let trackCount: Int
    public let releaseDate: Date?
    public let genre: String

    public init(
        id: Int,
        name: String,
        artistName: String,
        artworkURL: URL?,
        trackCount: Int,
        releaseDate: Date?,
        genre: String
    ) {
        self.id = id
        self.name = name
        self.artistName = artistName
        self.artworkURL = artworkURL
        self.trackCount = trackCount
        self.releaseDate = releaseDate
        self.genre = genre
    }

    /// Returns artwork URL at the requested size.
    public func artworkURL(size: Int) -> URL? {
        guard let artworkURL else { return nil }
        let urlString = artworkURL.absoluteString
            .replacingOccurrences(of: Constants.Artwork.defaultSizePattern, with: "\(size)x\(size)")
        return URL(string: urlString)
    }
}
