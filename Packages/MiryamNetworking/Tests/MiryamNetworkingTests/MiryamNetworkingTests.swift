import Foundation
import Testing

import MiryamCore
@testable import MiryamNetworking

// MARK: - ITunesSearchResponse Decoding

@Suite("ITunesSearchResponse Decoding")
struct ITunesSearchResponseDecodingTests {

    private static let validJSON = """
    {
        "resultCount": 2,
        "results": [
            {
                "wrapperType": "track",
                "trackId": 123,
                "trackName": "Test Song",
                "artistName": "Test Artist",
                "collectionName": "Test Album",
                "collectionId": 456,
                "artworkUrl100": "https://example.com/100x100.jpg",
                "previewUrl": "https://example.com/preview.m4a",
                "trackTimeMillis": 30000,
                "primaryGenreName": "Pop",
                "trackNumber": 1,
                "trackCount": 12,
                "releaseDate": "2024-01-15T12:00:00Z"
            },
            {
                "wrapperType": "collection",
                "trackId": 789,
                "trackName": "Collection Item",
                "artistName": "Artist"
            }
        ]
    }
    """

    @Test("Decodes valid JSON response with multiple tracks")
    func decodesValidResponseWithMultipleTracks() throws {
        let data = Data(Self.validJSON.utf8)
        let response = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)

        #expect(response.results.count == 2)

        let firstTrack = response.results[0]
        #expect(firstTrack.trackId == 123)
        #expect(firstTrack.trackName == "Test Song")
        #expect(firstTrack.artistName == "Test Artist")
        #expect(firstTrack.collectionName == "Test Album")
        #expect(firstTrack.collectionId == 456)
        #expect(firstTrack.artworkUrl100 == "https://example.com/100x100.jpg")
        #expect(firstTrack.previewUrl == "https://example.com/preview.m4a")
        #expect(firstTrack.trackTimeMillis == 30000)
        #expect(firstTrack.primaryGenreName == "Pop")
        #expect(firstTrack.trackNumber == 1)
        #expect(firstTrack.trackCount == 12)
        #expect(firstTrack.releaseDate == "2024-01-15T12:00:00Z")
        #expect(firstTrack.wrapperType == "track")

        let secondTrack = response.results[1]
        #expect(secondTrack.wrapperType == "collection")
        #expect(secondTrack.trackId == 789)
        #expect(secondTrack.trackName == "Collection Item")
        #expect(secondTrack.artistName == "Artist")
        #expect(secondTrack.collectionName == nil)
        #expect(secondTrack.collectionId == nil)
        #expect(secondTrack.previewUrl == nil)
    }

    @Test("Decodes empty results array")
    func decodesEmptyResults() throws {
        let json = """
        {
            "resultCount": 0,
            "results": []
        }
        """
        let data = Data(json.utf8)
        let response = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)

        #expect(response.resultCount == 0)
        #expect(response.results.isEmpty)
    }

    @Test("Decodes resultCount correctly")
    func decodesResultCount() throws {
        let data = Data(Self.validJSON.utf8)
        let response = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)

        #expect(response.resultCount == 2)
    }
}

// MARK: - ITunesTrack.toDomain()

@Suite("ITunesTrack.toDomain()")
struct ITunesTrackToDomainTests {

    @Test("Valid track with all fields maps to Song with correct values")
    func validTrackWithAllFieldsMapsCorrectly() {
        let track = ITunesTrack(
            trackId: 123,
            trackName: "Test Song",
            artistName: "Test Artist",
            collectionName: "Test Album",
            collectionId: 456,
            artworkUrl100: "https://example.com/100x100.jpg",
            previewUrl: "https://example.com/preview.m4a",
            trackTimeMillis: 210_000,
            primaryGenreName: "Pop",
            trackNumber: 3,
            trackCount: 12,
            releaseDate: "2024-01-15T12:00:00Z",
            wrapperType: "track"
        )

        let song = track.toDomain()

        #expect(song != nil)
        #expect(song?.id == 123)
        #expect(song?.name == "Test Song")
        #expect(song?.artistName == "Test Artist")
        #expect(song?.albumName == "Test Album")
        #expect(song?.albumId == 456)
        #expect(song?.artworkURL == URL(string: "https://example.com/100x100.jpg"))
        #expect(song?.previewURL == URL(string: "https://example.com/preview.m4a"))
        #expect(song?.durationInMilliseconds == 210_000)
        #expect(song?.genre == "Pop")
        #expect(song?.trackNumber == 3)
        #expect(song?.releaseDate != nil)
    }

    @Test("Track with wrapperType != 'track' returns nil")
    func nonTrackWrapperTypeReturnsNil() {
        let track = ITunesTrack(
            trackId: 789,
            trackName: "Collection Item",
            artistName: "Artist",
            collectionName: nil,
            collectionId: nil,
            artworkUrl100: nil,
            previewUrl: nil,
            trackTimeMillis: nil,
            primaryGenreName: nil,
            trackNumber: nil,
            trackCount: nil,
            releaseDate: nil,
            wrapperType: "collection"
        )

        #expect(track.toDomain() == nil)
    }

    @Test("Track with nil trackId returns nil")
    func nilTrackIdReturnsNil() {
        let track = ITunesTrack(
            trackId: nil,
            trackName: "Some Song",
            artistName: "Artist",
            collectionName: nil,
            collectionId: nil,
            artworkUrl100: nil,
            previewUrl: nil,
            trackTimeMillis: nil,
            primaryGenreName: nil,
            trackNumber: nil,
            trackCount: nil,
            releaseDate: nil,
            wrapperType: "track"
        )

        #expect(track.toDomain() == nil)
    }

    @Test("Track with nil trackName returns nil")
    func nilTrackNameReturnsNil() {
        let track = ITunesTrack(
            trackId: 100,
            trackName: nil,
            artistName: "Artist",
            collectionName: nil,
            collectionId: nil,
            artworkUrl100: nil,
            previewUrl: nil,
            trackTimeMillis: nil,
            primaryGenreName: nil,
            trackNumber: nil,
            trackCount: nil,
            releaseDate: nil,
            wrapperType: "track"
        )

        #expect(track.toDomain() == nil)
    }

    @Test("Track with nil wrapperType returns nil")
    func nilWrapperTypeReturnsNil() {
        let track = ITunesTrack(
            trackId: 100,
            trackName: "A Song",
            artistName: "Artist",
            collectionName: nil,
            collectionId: nil,
            artworkUrl100: nil,
            previewUrl: nil,
            trackTimeMillis: nil,
            primaryGenreName: nil,
            trackNumber: nil,
            trackCount: nil,
            releaseDate: nil,
            wrapperType: nil
        )

        #expect(track.toDomain() == nil)
    }

    @Test("Missing optional fields produce sensible defaults")
    func missingOptionalFieldsProduceDefaults() {
        let track = ITunesTrack(
            trackId: 42,
            trackName: "Minimal Song",
            artistName: nil,
            collectionName: nil,
            collectionId: nil,
            artworkUrl100: nil,
            previewUrl: nil,
            trackTimeMillis: nil,
            primaryGenreName: nil,
            trackNumber: nil,
            trackCount: nil,
            releaseDate: nil,
            wrapperType: "track"
        )

        let song = track.toDomain()

        #expect(song != nil)
        #expect(song?.id == 42)
        #expect(song?.name == "Minimal Song")
        #expect(song?.artistName == "Unknown Artist")
        #expect(song?.albumName == "Unknown Album")
        #expect(song?.albumId == 0)
        #expect(song?.artworkURL == nil)
        #expect(song?.previewURL == nil)
        #expect(song?.durationInMilliseconds == 0)
        #expect(song?.genre == "Unknown")
        #expect(song?.trackNumber == 0)
        #expect(song?.releaseDate == nil)
    }

    @Test("Valid ISO8601 releaseDate is parsed correctly")
    func validISO8601ReleaseDateIsParsed() {
        let track = ITunesTrack(
            trackId: 1,
            trackName: "Dated Song",
            artistName: "Artist",
            collectionName: nil,
            collectionId: nil,
            artworkUrl100: nil,
            previewUrl: nil,
            trackTimeMillis: nil,
            primaryGenreName: nil,
            trackNumber: nil,
            trackCount: nil,
            releaseDate: "2024-01-15T12:00:00Z",
            wrapperType: "track"
        )

        let song = track.toDomain()
        #expect(song != nil)

        let expectedDate = ISO8601DateFormatter().date(from: "2024-01-15T12:00:00Z")
        #expect(song?.releaseDate == expectedDate)
    }

    @Test("Invalid releaseDate string produces nil date")
    func invalidReleaseDateProducesNilDate() {
        let track = ITunesTrack(
            trackId: 2,
            trackName: "Bad Date Song",
            artistName: "Artist",
            collectionName: nil,
            collectionId: nil,
            artworkUrl100: nil,
            previewUrl: nil,
            trackTimeMillis: nil,
            primaryGenreName: nil,
            trackNumber: nil,
            trackCount: nil,
            releaseDate: "not-a-date",
            wrapperType: "track"
        )

        let song = track.toDomain()
        #expect(song != nil)
        #expect(song?.releaseDate == nil)
    }
}

// MARK: - ITunesEndpoint

@Suite("ITunesEndpoint")
struct ITunesEndpointTests {

    @Test("Search URL has correct base URL")
    func searchURLHasCorrectBaseURL() throws {
        let url = try ITunesEndpoint.search(query: "test", limit: 25, offset: 0).makeURL()
        #expect(url.scheme == "https")
        #expect(url.host == "itunes.apple.com")
        #expect(url.path == "/search" || url.path() == "/search")
    }

    @Test("Search URL contains all required query parameters")
    func searchURLContainsAllQueryParameters() throws {
        let url = try ITunesEndpoint.search(query: "taylor swift", limit: 20, offset: 10).makeURL()
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        let term = queryItems.first(where: { $0.name == "term" })
        #expect(term?.value == "taylor swift")

        let media = queryItems.first(where: { $0.name == "media" })
        #expect(media?.value == "music")

        let entity = queryItems.first(where: { $0.name == "entity" })
        #expect(entity?.value == "song")

        let limit = queryItems.first(where: { $0.name == "limit" })
        #expect(limit?.value == "20")

        let offset = queryItems.first(where: { $0.name == "offset" })
        #expect(offset?.value == "10")
    }

    @Test("Search URL encodes special characters in query")
    func searchURLEncodesSpecialCharacters() throws {
        let url = try ITunesEndpoint.search(query: "rock & roll", limit: 10, offset: 0).makeURL()
        let urlString = url.absoluteString

        // The ampersand in the query value must be percent-encoded so it is
        // not misinterpreted as a query-item separator.
        #expect(urlString.contains("rock%20%26%20roll") || urlString.contains("rock+%26+roll"))
        #expect(urlString.contains("term="))
    }

    @Test("Search URL encodes unicode characters in query")
    func searchURLEncodesUnicodeCharacters() throws {
        let url = try ITunesEndpoint.search(query: "cafe\u{0301}", limit: 5, offset: 0).makeURL()
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let term = components?.queryItems?.first(where: { $0.name == "term" })

        #expect(term?.value == "cafe\u{0301}")
    }

    @Test("Lookup URL has correct base URL and path")
    func lookupURLHasCorrectBaseAndPath() throws {
        let url = try ITunesEndpoint.lookup(albumId: 999).makeURL()
        #expect(url.scheme == "https")
        #expect(url.host == "itunes.apple.com")
        #expect(url.path == "/lookup" || url.path() == "/lookup")
    }

    @Test("Lookup URL contains correct id and entity parameters")
    func lookupURLContainsCorrectParameters() throws {
        let url = try ITunesEndpoint.lookup(albumId: 456).makeURL()
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        let idItem = queryItems.first(where: { $0.name == "id" })
        #expect(idItem?.value == "456")

        let entityItem = queryItems.first(where: { $0.name == "entity" })
        #expect(entityItem?.value == "song")
    }

    @Test("Search and lookup produce distinct paths")
    func searchAndLookupProduceDistinctPaths() throws {
        let searchURL = try ITunesEndpoint.search(query: "test", limit: 10, offset: 0).makeURL()
        let lookupURL = try ITunesEndpoint.lookup(albumId: 1).makeURL()

        #expect(searchURL.path != lookupURL.path)
    }

    @Test("Search URL handles emoji in query")
    func searchURLHandlesEmojiInQuery() throws {
        let url = try ITunesEndpoint.search(query: "🎵 music", limit: 10, offset: 0).makeURL()
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let term = components?.queryItems?.first(where: { $0.name == "term" })

        #expect(term?.value == "🎵 music")
    }
}
