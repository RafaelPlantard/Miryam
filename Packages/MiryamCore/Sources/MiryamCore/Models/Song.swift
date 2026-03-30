import Foundation

/// A song from the iTunes catalog.
public struct Song: Sendable, Identifiable, Hashable, Codable {
    public let id: Int
    public let name: String
    public let artistName: String
    public let albumName: String
    public let albumId: Int
    public let artworkURL: URL?
    public let previewURL: URL?
    public let durationInMilliseconds: Int
    public let genre: String
    public let trackNumber: Int
    public let releaseDate: Date?

    public init(
        id: Int,
        name: String,
        artistName: String,
        albumName: String,
        albumId: Int,
        artworkURL: URL?,
        previewURL: URL?,
        durationInMilliseconds: Int,
        genre: String,
        trackNumber: Int,
        releaseDate: Date?
    ) {
        self.id = id
        self.name = name
        self.artistName = artistName
        self.albumName = albumName
        self.albumId = albumId
        self.artworkURL = artworkURL
        self.previewURL = previewURL
        self.durationInMilliseconds = durationInMilliseconds
        self.genre = genre
        self.trackNumber = trackNumber
        self.releaseDate = releaseDate
    }

    /// Duration formatted as "m:ss"
    public var formattedDuration: String {
        let totalSeconds = durationInMilliseconds / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Returns artwork URL at the requested size (replaces 100x100 default).
    public func artworkURL(size: Int) -> URL? {
        guard let artworkURL else { return nil }
        let urlString = artworkURL.absoluteString
            .replacingOccurrences(of: Constants.Artwork.defaultSizePattern, with: "\(size)x\(size)")
        return URL(string: urlString)
    }
}
