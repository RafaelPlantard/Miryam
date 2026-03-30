import Foundation
import Testing
@testable import MiryamCore

// MARK: - Song Tests

@Suite("Song")
struct SongTests {

    // MARK: - Helpers

    private func makeSong(
        id: Int = 1,
        name: String = "Test Song",
        artistName: String = "Test Artist",
        albumName: String = "Test Album",
        albumId: Int = 100,
        artworkURL: URL? = URL(string: "https://example.com/art/100x100bb.jpg"),
        previewURL: URL? = URL(string: "https://example.com/preview.m4a"),
        durationInMilliseconds: Int = 213000,
        genre: String = "Pop",
        trackNumber: Int = 1,
        releaseDate: Date? = nil
    ) -> Song {
        Song(
            id: id,
            name: name,
            artistName: artistName,
            albumName: albumName,
            albumId: albumId,
            artworkURL: artworkURL,
            previewURL: previewURL,
            durationInMilliseconds: durationInMilliseconds,
            genre: genre,
            trackNumber: trackNumber,
            releaseDate: releaseDate
        )
    }

    // MARK: - formattedDuration

    @Test("formattedDuration for 0ms returns 0:00")
    func formattedDurationZero() {
        let song = makeSong(durationInMilliseconds: 0)
        #expect(song.formattedDuration == "0:00")
    }

    @Test("formattedDuration for 30000ms returns 0:30")
    func formattedDurationThirtySeconds() {
        let song = makeSong(durationInMilliseconds: 30000)
        #expect(song.formattedDuration == "0:30")
    }

    @Test("formattedDuration for 213000ms returns 3:33")
    func formattedDurationThreeMinutesThirtyThree() {
        let song = makeSong(durationInMilliseconds: 213000)
        #expect(song.formattedDuration == "3:33")
    }

    @Test("formattedDuration for 61000ms returns 1:01")
    func formattedDurationOneMinuteOne() {
        let song = makeSong(durationInMilliseconds: 61000)
        #expect(song.formattedDuration == "1:01")
    }

    @Test("formattedDuration for 600000ms returns 10:00")
    func formattedDurationTenMinutes() {
        let song = makeSong(durationInMilliseconds: 600000)
        #expect(song.formattedDuration == "10:00")
    }

    @Test("formattedDuration truncates sub-second remainder")
    func formattedDurationTruncatesMilliseconds() {
        // 1999ms = 1.999s -> truncates to 1s -> 0:01
        let song = makeSong(durationInMilliseconds: 1999)
        #expect(song.formattedDuration == "0:01")
    }

    // MARK: - artworkURL(size:)

    @Test("artworkURL(size:) replaces 100x100 with requested size")
    func artworkURLReplacesSize() {
        let song = makeSong(artworkURL: URL(string: "https://example.com/art/100x100bb.jpg"))
        let result = song.artworkURL(size: 300)
        #expect(result == URL(string: "https://example.com/art/300x300bb.jpg"))
    }

    @Test("artworkURL(size:) returns nil when artworkURL is nil")
    func artworkURLReturnsNilWhenNil() {
        let song = makeSong(artworkURL: nil)
        let result = song.artworkURL(size: 300)
        #expect(result == nil)
    }

    @Test("artworkURL(size:) preserves URL when no 100x100 pattern present")
    func artworkURLPreservesWhenNoPattern() {
        let song = makeSong(artworkURL: URL(string: "https://example.com/art/image.jpg"))
        let result = song.artworkURL(size: 300)
        #expect(result == URL(string: "https://example.com/art/image.jpg"))
    }

    // MARK: - Codable

    @Test("Song round-trips through JSON encoding and decoding")
    func codableRoundTrip() throws {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let original = makeSong(
            id: 42,
            name: "Encoded Song",
            artistName: "Encoder",
            albumName: "Codable Album",
            albumId: 200,
            durationInMilliseconds: 180000,
            genre: "Rock",
            trackNumber: 3,
            releaseDate: date
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Song.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
        #expect(decoded.artistName == original.artistName)
        #expect(decoded.albumName == original.albumName)
        #expect(decoded.albumId == original.albumId)
        #expect(decoded.artworkURL == original.artworkURL)
        #expect(decoded.previewURL == original.previewURL)
        #expect(decoded.durationInMilliseconds == original.durationInMilliseconds)
        #expect(decoded.genre == original.genre)
        #expect(decoded.trackNumber == original.trackNumber)
        #expect(decoded.releaseDate == original.releaseDate)
    }

    @Test("Song Codable round-trip with nil optional fields")
    func codableRoundTripWithNils() throws {
        let original = makeSong(artworkURL: nil, previewURL: nil, releaseDate: nil)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Song.self, from: data)

        #expect(decoded.artworkURL == nil)
        #expect(decoded.previewURL == nil)
        #expect(decoded.releaseDate == nil)
    }

    // MARK: - Hashable / Equatable

    @Test("Identical songs are equal")
    func equalSongsAreEqual() {
        let song1 = makeSong(id: 1, name: "Same Song")
        let song2 = makeSong(id: 1, name: "Same Song")
        #expect(song1 == song2)
    }

    @Test("Songs with different ids are not equal")
    func differentIdSongsAreNotEqual() {
        let song1 = makeSong(id: 1)
        let song2 = makeSong(id: 2)
        #expect(song1 != song2)
    }

    @Test("Songs with different names are not equal")
    func differentNameSongsAreNotEqual() {
        let song1 = makeSong(name: "Song A")
        let song2 = makeSong(name: "Song B")
        #expect(song1 != song2)
    }

    @Test("Equal songs produce the same hash value")
    func equalSongsHashEqual() {
        let song1 = makeSong(id: 1, name: "Hash Song")
        let song2 = makeSong(id: 1, name: "Hash Song")
        #expect(song1.hashValue == song2.hashValue)
    }

    @Test("Songs can be used in a Set")
    func songsInSet() {
        let song1 = makeSong(id: 1)
        let song2 = makeSong(id: 2)
        let duplicate = makeSong(id: 1)
        let set: Set<Song> = [song1, song2, duplicate]
        #expect(set.count == 2)
    }

    // MARK: - Identifiable

    @Test("Song id matches the provided id")
    func identifiableId() {
        let song = makeSong(id: 99)
        #expect(song.id == 99)
    }
}

// MARK: - Album Tests

@Suite("Album")
struct AlbumTests {

    // MARK: - Helpers

    private func makeAlbum(
        id: Int = 1,
        name: String = "Test Album",
        artistName: String = "Test Artist",
        artworkURL: URL? = URL(string: "https://example.com/art/100x100bb.jpg"),
        trackCount: Int = 12,
        releaseDate: Date? = nil,
        genre: String = "Pop"
    ) -> Album {
        Album(
            id: id,
            name: name,
            artistName: artistName,
            artworkURL: artworkURL,
            trackCount: trackCount,
            releaseDate: releaseDate,
            genre: genre
        )
    }

    // MARK: - artworkURL(size:)

    @Test("artworkURL(size:) replaces 100x100 with requested size")
    func artworkURLReplacesSize() {
        let album = makeAlbum(artworkURL: URL(string: "https://example.com/art/100x100bb.jpg"))
        let result = album.artworkURL(size: 600)
        #expect(result == URL(string: "https://example.com/art/600x600bb.jpg"))
    }

    @Test("artworkURL(size:) returns nil when artworkURL is nil")
    func artworkURLReturnsNilWhenNil() {
        let album = makeAlbum(artworkURL: nil)
        let result = album.artworkURL(size: 600)
        #expect(result == nil)
    }

    @Test("artworkURL(size:) preserves URL when no 100x100 pattern present")
    func artworkURLPreservesWhenNoPattern() {
        let album = makeAlbum(artworkURL: URL(string: "https://example.com/art/image.jpg"))
        let result = album.artworkURL(size: 600)
        #expect(result == URL(string: "https://example.com/art/image.jpg"))
    }

    // MARK: - Codable

    @Test("Album round-trips through JSON encoding and decoding")
    func codableRoundTrip() throws {
        let date = Date(timeIntervalSince1970: 1_500_000)
        let original = makeAlbum(
            id: 55,
            name: "Codable Album",
            artistName: "Encoder",
            trackCount: 10,
            releaseDate: date,
            genre: "Jazz"
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Album.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
        #expect(decoded.artistName == original.artistName)
        #expect(decoded.artworkURL == original.artworkURL)
        #expect(decoded.trackCount == original.trackCount)
        #expect(decoded.releaseDate == original.releaseDate)
        #expect(decoded.genre == original.genre)
    }

    @Test("Album Codable round-trip with nil optional fields")
    func codableRoundTripWithNils() throws {
        let original = makeAlbum(artworkURL: nil, releaseDate: nil)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Album.self, from: data)

        #expect(decoded.artworkURL == nil)
        #expect(decoded.releaseDate == nil)
    }

    // MARK: - Hashable / Equatable

    @Test("Identical albums are equal")
    func equalAlbumsAreEqual() {
        let album1 = makeAlbum(id: 1, name: "Same Album")
        let album2 = makeAlbum(id: 1, name: "Same Album")
        #expect(album1 == album2)
    }

    @Test("Albums with different ids are not equal")
    func differentIdAlbumsAreNotEqual() {
        let album1 = makeAlbum(id: 1)
        let album2 = makeAlbum(id: 2)
        #expect(album1 != album2)
    }

    @Test("Albums can be used in a Set")
    func albumsInSet() {
        let album1 = makeAlbum(id: 1)
        let album2 = makeAlbum(id: 2)
        let duplicate = makeAlbum(id: 1)
        let set: Set<Album> = [album1, album2, duplicate]
        #expect(set.count == 2)
    }

    // MARK: - Identifiable

    @Test("Album id matches the provided id")
    func identifiableId() {
        let album = makeAlbum(id: 77)
        #expect(album.id == 77)
    }
}

// MARK: - Pagination Tests

@Suite("Pagination")
struct PaginationTests {

    @Test("Initial state has offset 0, hasMorePages true, and default limit 25")
    func initialState() {
        let pagination = Pagination()
        #expect(pagination.limit == 25)
        #expect(pagination.offset == 0)
        #expect(pagination.hasMorePages == true)
    }

    @Test("Custom limit is respected")
    func customLimit() {
        let pagination = Pagination(limit: 50)
        #expect(pagination.limit == 50)
        #expect(pagination.offset == 0)
        #expect(pagination.hasMorePages == true)
    }

    @Test("Advance with full page sets hasMorePages to true")
    func advanceFullPage() {
        var pagination = Pagination(limit: 25)
        pagination.advance(resultCount: 25)
        #expect(pagination.offset == 25)
        #expect(pagination.hasMorePages == true)
    }

    @Test("Advance with more than limit sets hasMorePages to true")
    func advanceOverLimit() {
        var pagination = Pagination(limit: 25)
        pagination.advance(resultCount: 30)
        #expect(pagination.offset == 30)
        #expect(pagination.hasMorePages == true)
    }

    @Test("Advance with partial page sets hasMorePages to false")
    func advancePartialPage() {
        var pagination = Pagination(limit: 25)
        pagination.advance(resultCount: 10)
        #expect(pagination.offset == 10)
        #expect(pagination.hasMorePages == false)
    }

    @Test("Advance with zero results sets hasMorePages to false")
    func advanceZeroResults() {
        var pagination = Pagination(limit: 25)
        pagination.advance(resultCount: 0)
        #expect(pagination.offset == 0)
        #expect(pagination.hasMorePages == false)
    }

    @Test("Multiple advances accumulate offset")
    func multipleAdvances() {
        var pagination = Pagination(limit: 25)
        pagination.advance(resultCount: 25)
        pagination.advance(resultCount: 25)
        pagination.advance(resultCount: 15)
        #expect(pagination.offset == 65)
        #expect(pagination.hasMorePages == false)
    }

    @Test("Reset after advancing restores initial state")
    func resetAfterAdvancing() {
        var pagination = Pagination(limit: 25)
        pagination.advance(resultCount: 25)
        pagination.advance(resultCount: 10)
        #expect(pagination.offset == 35)
        #expect(pagination.hasMorePages == false)

        pagination.reset()
        #expect(pagination.offset == 0)
        #expect(pagination.hasMorePages == true)
    }

    @Test("Reset preserves the original limit")
    func resetPreservesLimit() {
        var pagination = Pagination(limit: 50)
        pagination.advance(resultCount: 50)
        pagination.reset()
        #expect(pagination.limit == 50)
    }
}

// MARK: - PlaybackState Tests

@Suite("PlaybackState")
struct PlaybackStateTests {

    // MARK: - Default init

    @Test("Default init has idle status and zero values")
    func defaultInit() {
        let state = PlaybackState()
        #expect(state.currentSong == nil)
        #expect(state.currentTime == 0)
        #expect(state.duration == 0)
        #expect(state.progress == 0)
        if case .idle = state.status {
            // expected
        } else {
            Issue.record("Expected idle status, got \(state.status)")
        }
    }

    // MARK: - formattedCurrentTime

    @Test("formattedCurrentTime for 0 seconds returns 0:00")
    func formattedCurrentTimeZero() {
        let state = PlaybackState(currentTime: 0)
        #expect(state.formattedCurrentTime == "0:00")
    }

    @Test("formattedCurrentTime for 65 seconds returns 1:05")
    func formattedCurrentTimeSixtyFive() {
        let state = PlaybackState(currentTime: 65)
        #expect(state.formattedCurrentTime == "1:05")
    }

    @Test("formattedCurrentTime for 125.7 seconds returns 2:05")
    func formattedCurrentTimeWithFraction() {
        let state = PlaybackState(currentTime: 125.7)
        #expect(state.formattedCurrentTime == "2:05")
    }

    @Test("formattedCurrentTime for 59 seconds returns 0:59")
    func formattedCurrentTimeFiftyNine() {
        let state = PlaybackState(currentTime: 59)
        #expect(state.formattedCurrentTime == "0:59")
    }

    @Test("formattedCurrentTime for 600 seconds returns 10:00")
    func formattedCurrentTimeTenMinutes() {
        let state = PlaybackState(currentTime: 600)
        #expect(state.formattedCurrentTime == "10:00")
    }

    // MARK: - formattedRemainingTime

    @Test("formattedRemainingTime with duration 180 and currentTime 60 returns -2:00")
    func formattedRemainingTimeTwoMinutes() {
        let state = PlaybackState(currentTime: 60, duration: 180)
        #expect(state.formattedRemainingTime == "-2:00")
    }

    @Test("formattedRemainingTime at start of song returns full duration")
    func formattedRemainingTimeAtStart() {
        let state = PlaybackState(currentTime: 0, duration: 240)
        #expect(state.formattedRemainingTime == "-4:00")
    }

    @Test("formattedRemainingTime at end of song returns -0:00")
    func formattedRemainingTimeAtEnd() {
        let state = PlaybackState(currentTime: 180, duration: 180)
        #expect(state.formattedRemainingTime == "-0:00")
    }

    @Test("formattedRemainingTime clamps negative remaining to zero")
    func formattedRemainingTimeClamps() {
        // currentTime exceeds duration
        let state = PlaybackState(currentTime: 200, duration: 180)
        #expect(state.formattedRemainingTime == "-0:00")
    }

    @Test("formattedRemainingTime with fractional seconds truncates correctly")
    func formattedRemainingTimeFractional() {
        // duration=180, currentTime=60.9 -> remaining = 119.1 -> Int(119.1) = 119 -> 1:59
        let state = PlaybackState(currentTime: 60.9, duration: 180)
        #expect(state.formattedRemainingTime == "-1:59")
    }

    // MARK: - Status

    @Test("PlaybackState can be initialized with each status variant")
    func statusVariants() {
        let idle = PlaybackState(status: .idle)
        if case .idle = idle.status {} else {
            Issue.record("Expected idle")
        }

        let loading = PlaybackState(status: .loading)
        if case .loading = loading.status {} else {
            Issue.record("Expected loading")
        }

        let playing = PlaybackState(status: .playing)
        if case .playing = playing.status {} else {
            Issue.record("Expected playing")
        }

        let paused = PlaybackState(status: .paused)
        if case .paused = paused.status {} else {
            Issue.record("Expected paused")
        }

        let failed = PlaybackState(status: .failed(.playbackFailed("test")))
        if case .failed(let error) = failed.status {
            #expect(error == .playbackFailed("test"))
        } else {
            Issue.record("Expected failed")
        }
    }

    // MARK: - Custom init

    @Test("PlaybackState accepts a currentSong")
    func customInitWithSong() {
        let song = Song(
            id: 1,
            name: "Test",
            artistName: "Artist",
            albumName: "Album",
            albumId: 10,
            artworkURL: nil,
            previewURL: nil,
            durationInMilliseconds: 200000,
            genre: "Pop",
            trackNumber: 1,
            releaseDate: nil
        )
        let state = PlaybackState(status: .playing, currentSong: song, currentTime: 30, duration: 200, progress: 0.15)
        #expect(state.currentSong?.id == 1)
        #expect(state.currentTime == 30)
        #expect(state.duration == 200)
        #expect(state.progress == 0.15)
    }
}

// MARK: - AppError Tests

@Suite("AppError")
struct AppErrorTests {

    // MARK: - userMessage

    @Test("networkError userMessage")
    func networkErrorMessage() {
        let error = AppError.networkError("timeout")
        #expect(error.userMessage == "Unable to connect. Please check your internet connection.")
    }

    @Test("decodingError userMessage")
    func decodingErrorMessage() {
        let error = AppError.decodingError("invalid JSON")
        #expect(error.userMessage == "Something went wrong while loading data.")
    }

    @Test("noInternetConnection userMessage")
    func noInternetConnectionMessage() {
        let error = AppError.noInternetConnection
        #expect(error.userMessage == "No internet connection. Showing cached results.")
    }

    @Test("serverError userMessage includes status code")
    func serverErrorMessage() {
        let error = AppError.serverError(statusCode: 500)
        #expect(error.userMessage == "Server error (500). Please try again later.")
    }

    @Test("serverError userMessage with 404 status code")
    func serverError404Message() {
        let error = AppError.serverError(statusCode: 404)
        #expect(error.userMessage == "Server error (404). Please try again later.")
    }

    @Test("notFound userMessage")
    func notFoundMessage() {
        let error = AppError.notFound
        #expect(error.userMessage == "No results found.")
    }

    @Test("playbackFailed userMessage")
    func playbackFailedMessage() {
        let error = AppError.playbackFailed("codec error")
        #expect(error.userMessage == "Unable to play this song. Please try another.")
    }

    @Test("cacheError userMessage")
    func cacheErrorMessage() {
        let error = AppError.cacheError("disk full")
        #expect(error.userMessage == "Unable to access saved data.")
    }

    @Test("unknown userMessage")
    func unknownMessage() {
        let error = AppError.unknown("mystery")
        #expect(error.userMessage == "An unexpected error occurred.")
    }

    // MARK: - Equatable

    @Test("Same case with same associated value are equal")
    func equatableSameCase() {
        #expect(AppError.networkError("timeout") == AppError.networkError("timeout"))
        #expect(AppError.serverError(statusCode: 500) == AppError.serverError(statusCode: 500))
        #expect(AppError.noInternetConnection == AppError.noInternetConnection)
        #expect(AppError.notFound == AppError.notFound)
    }

    @Test("Same case with different associated values are not equal")
    func equatableDifferentAssociatedValues() {
        #expect(AppError.networkError("timeout") != AppError.networkError("refused"))
        #expect(AppError.serverError(statusCode: 500) != AppError.serverError(statusCode: 503))
        #expect(AppError.playbackFailed("a") != AppError.playbackFailed("b"))
        #expect(AppError.cacheError("x") != AppError.cacheError("y"))
        #expect(AppError.unknown("a") != AppError.unknown("b"))
        #expect(AppError.decodingError("a") != AppError.decodingError("b"))
    }

    @Test("Different cases are not equal")
    func equatableDifferentCases() {
        #expect(AppError.networkError("err") != AppError.decodingError("err"))
        #expect(AppError.noInternetConnection != AppError.notFound)
        #expect(AppError.playbackFailed("err") != AppError.cacheError("err"))
        #expect(AppError.unknown("err") != AppError.networkError("err"))
    }

    // MARK: - Error conformance

    @Test("AppError conforms to Error protocol")
    func errorConformance() {
        let error: any Error = AppError.networkError("test")
        #expect(error is AppError)
    }
}
