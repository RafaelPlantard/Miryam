import Foundation

/// Raw response from the iTunes Search API.
struct ITunesSearchResponse: Decodable, Sendable {
    let resultCount: Int
    let results: [ITunesTrack]
}

/// Raw track from iTunes API — maps to domain Song.
struct ITunesTrack: Decodable, Sendable {
    let trackId: Int?
    let trackName: String?
    let artistName: String?
    let collectionName: String?
    let collectionId: Int?
    let artworkUrl100: String?
    let previewUrl: String?
    let trackTimeMillis: Int?
    let primaryGenreName: String?
    let trackNumber: Int?
    let trackCount: Int?
    let releaseDate: String?
    let wrapperType: String?
}
