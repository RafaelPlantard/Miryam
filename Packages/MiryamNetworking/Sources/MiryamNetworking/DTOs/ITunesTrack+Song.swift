import Foundation
import MiryamCore

extension ITunesTrack {
    /// Maps iTunes DTO to domain Song. Returns nil if essential fields are missing.
    func toDomain() -> Song? {
        guard let trackId, let trackName, wrapperType == APIConstants.WrapperType.track else { return nil }

        let dateFormatter = ISO8601DateFormatter()

        return Song(
            id: trackId,
            name: trackName,
            artistName: artistName ?? Constants.Fallback.artistName,
            albumName: collectionName ?? Constants.Fallback.albumName,
            albumId: collectionId ?? 0,
            artworkURL: artworkUrl100.flatMap { URL(string: $0) },
            previewURL: previewUrl.flatMap { URL(string: $0) },
            durationInMilliseconds: trackTimeMillis ?? 0,
            genre: primaryGenreName ?? Constants.Fallback.genre,
            trackNumber: trackNumber ?? 0,
            releaseDate: releaseDate.flatMap { dateFormatter.date(from: $0) }
        )
    }
}
