import Testing
import Foundation
import MiryamCore

@Suite("App Integration")
struct MiryamTests {

    @Test("Song model round-trip through Codable")
    func songCodableRoundTrip() throws {
        let song = Song(
            id: 1, name: "Test Song", artistName: "Artist",
            albumName: "Album", albumId: 100,
            artworkURL: URL(string: "https://example.com/100x100.jpg"),
            previewURL: URL(string: "https://example.com/preview.m4a"),
            durationInMilliseconds: 30000, genre: "Pop",
            trackNumber: 1, releaseDate: nil
        )

        let data = try JSONEncoder().encode(song)
        let decoded = try JSONDecoder().decode(Song.self, from: data)

        #expect(decoded.id == song.id)
        #expect(decoded.name == song.name)
        #expect(decoded.formattedDuration == "0:30")
    }

    @Test("Album artwork URL resizing")
    func albumArtworkResizing() {
        let album = Album(
            id: 1, name: "Test Album", artistName: "Artist",
            artworkURL: URL(string: "https://example.com/100x100.jpg"),
            trackCount: 10, releaseDate: nil, genre: "Pop"
        )

        let resized = album.artworkURL(size: 600)
        #expect(resized?.absoluteString.contains("600x600") == true)
    }

    @Test("Pagination state machine")
    func paginationStateMachine() {
        var pagination = Pagination(limit: 25)

        #expect(pagination.offset == 0)
        #expect(pagination.hasMorePages == true)

        pagination.advance(resultCount: 25)
        #expect(pagination.offset == 25)
        #expect(pagination.hasMorePages == true)

        pagination.advance(resultCount: 10)
        #expect(pagination.offset == 35)
        #expect(pagination.hasMorePages == false)

        pagination.reset()
        #expect(pagination.offset == 0)
        #expect(pagination.hasMorePages == true)
    }

    @Test("PlaybackState time formatting")
    func playbackStateFormatting() {
        let state = PlaybackState(
            status: .playing,
            currentSong: nil,
            currentTime: 65,
            duration: 180,
            progress: 65.0 / 180.0
        )

        #expect(state.formattedCurrentTime == "1:05")
        #expect(state.formattedRemainingTime == "-1:55")
    }

    @Test("AppError user messages are non-empty")
    func appErrorUserMessages() {
        let errors: [AppError] = [
            .networkError("test"),
            .decodingError("test"),
            .noInternetConnection,
            .serverError(statusCode: 500),
            .notFound,
            .playbackFailed("test"),
            .cacheError("test"),
            .unknown("test")
        ]

        for error in errors {
            #expect(!error.userMessage.isEmpty)
        }
    }
}
