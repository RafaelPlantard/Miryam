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

    /// Duration formatted as "m:ss" — computed once at init.
    public let formattedDuration: String

    private enum CodingKeys: String, CodingKey {
        case id, name, artistName, albumName, albumId
        case artworkURL, previewURL, durationInMilliseconds
        case genre, trackNumber, releaseDate
    }

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
        self.formattedDuration = Self.formatDuration(durationInMilliseconds)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.artistName = try container.decode(String.self, forKey: .artistName)
        self.albumName = try container.decode(String.self, forKey: .albumName)
        self.albumId = try container.decode(Int.self, forKey: .albumId)
        self.artworkURL = try container.decodeIfPresent(URL.self, forKey: .artworkURL)
        self.previewURL = try container.decodeIfPresent(URL.self, forKey: .previewURL)
        self.durationInMilliseconds = try container.decode(Int.self, forKey: .durationInMilliseconds)
        self.genre = try container.decode(String.self, forKey: .genre)
        self.trackNumber = try container.decode(Int.self, forKey: .trackNumber)
        self.releaseDate = try container.decodeIfPresent(Date.self, forKey: .releaseDate)
        self.formattedDuration = Self.formatDuration(durationInMilliseconds)
    }

    private static func formatDuration(_ milliseconds: Int) -> String {
        let totalSeconds = milliseconds / 1000
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
