import Foundation
import MiryamCore
import SwiftData

/// SwiftData model for persisted songs.
@Model
public final class CachedSong {
    @Attribute(.unique) public var songId: Int
    public var name: String
    public var artistName: String
    public var albumName: String
    public var albumId: Int
    public var artworkURLString: String?
    public var previewURLString: String?
    public var durationInMilliseconds: Int
    public var genre: String
    public var trackNumber: Int
    public var releaseDate: Date?
    public var cachedAt: Date
    public var lastPlayedAt: Date?
    public var searchQuery: String?

    public init(from song: Song, query: String? = nil) {
        self.songId = song.id
        self.name = song.name
        self.artistName = song.artistName
        self.albumName = song.albumName
        self.albumId = song.albumId
        self.artworkURLString = song.artworkURL?.absoluteString
        self.previewURLString = song.previewURL?.absoluteString
        self.durationInMilliseconds = song.durationInMilliseconds
        self.genre = song.genre
        self.trackNumber = song.trackNumber
        self.releaseDate = song.releaseDate
        self.cachedAt = Date()
        self.lastPlayedAt = nil
        self.searchQuery = query
    }

    /// Convert back to domain model.
    public func toDomain() -> Song {
        Song(
            id: songId,
            name: name,
            artistName: artistName,
            albumName: albumName,
            albumId: albumId,
            artworkURL: artworkURLString.flatMap { URL(string: $0) },
            previewURL: previewURLString.flatMap { URL(string: $0) },
            durationInMilliseconds: durationInMilliseconds,
            genre: genre,
            trackNumber: trackNumber,
            releaseDate: releaseDate
        )
    }
}
