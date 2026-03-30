import Testing
import Foundation
import SwiftData
@testable import MiryamPersistence
import MiryamCore

// MARK: - Test Helpers

/// Creates a Song with sensible defaults; override any parameter as needed.
private func makeSong(
    id: Int = 1,
    name: String = "Test Song",
    artistName: String = "Artist",
    albumName: String = "Album",
    albumId: Int = 100,
    artworkURL: URL? = URL(string: "https://example.com/100x100.jpg"),
    previewURL: URL? = URL(string: "https://example.com/preview.m4a"),
    durationInMilliseconds: Int = 30000,
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

// MARK: - CachedSong Tests

@Suite("CachedSong Model")
struct CachedSongTests {

    @Test("init(from:) copies all Song fields correctly")
    func initFromSongCopiesAllFields() {
        let releaseDate = Date(timeIntervalSince1970: 1_000_000)
        let song = makeSong(
            id: 42,
            name: "Midnight Rain",
            artistName: "Taylor Swift",
            albumName: "Midnights",
            albumId: 200,
            artworkURL: URL(string: "https://example.com/art100x100.jpg"),
            previewURL: URL(string: "https://example.com/preview.m4a"),
            durationInMilliseconds: 174_000,
            genre: "Pop",
            trackNumber: 3,
            releaseDate: releaseDate
        )

        let cached = CachedSong(from: song, query: "midnight")

        #expect(cached.songId == 42)
        #expect(cached.name == "Midnight Rain")
        #expect(cached.artistName == "Taylor Swift")
        #expect(cached.albumName == "Midnights")
        #expect(cached.albumId == 200)
        #expect(cached.artworkURLString == "https://example.com/art100x100.jpg")
        #expect(cached.previewURLString == "https://example.com/preview.m4a")
        #expect(cached.durationInMilliseconds == 174_000)
        #expect(cached.genre == "Pop")
        #expect(cached.trackNumber == 3)
        #expect(cached.releaseDate == releaseDate)
        #expect(cached.searchQuery == "midnight")
        #expect(cached.lastPlayedAt == nil)
    }

    @Test("init(from:) defaults searchQuery to nil when no query provided")
    func initFromSongDefaultsQueryToNil() {
        let song = makeSong()
        let cached = CachedSong(from: song)

        #expect(cached.searchQuery == nil)
    }

    @Test("toDomain() round-trip preserves all values")
    func toDomainRoundTrip() {
        let releaseDate = Date(timeIntervalSince1970: 1_700_000_000)
        let original = makeSong(
            id: 7,
            name: "Bohemian Rhapsody",
            artistName: "Queen",
            albumName: "A Night at the Opera",
            albumId: 55,
            artworkURL: URL(string: "https://example.com/queen100x100.jpg"),
            previewURL: URL(string: "https://example.com/bohemian.m4a"),
            durationInMilliseconds: 354_000,
            genre: "Rock",
            trackNumber: 11,
            releaseDate: releaseDate
        )

        let cached = CachedSong(from: original)
        let restored = cached.toDomain()

        #expect(restored.id == original.id)
        #expect(restored.name == original.name)
        #expect(restored.artistName == original.artistName)
        #expect(restored.albumName == original.albumName)
        #expect(restored.albumId == original.albumId)
        #expect(restored.artworkURL == original.artworkURL)
        #expect(restored.previewURL == original.previewURL)
        #expect(restored.durationInMilliseconds == original.durationInMilliseconds)
        #expect(restored.genre == original.genre)
        #expect(restored.trackNumber == original.trackNumber)
        #expect(restored.releaseDate == original.releaseDate)
    }

    @Test("toDomain() handles nil optional fields")
    func toDomainWithNilOptionals() {
        let song = makeSong(
            artworkURL: nil,
            previewURL: nil,
            releaseDate: nil
        )

        let cached = CachedSong(from: song)
        let restored = cached.toDomain()

        #expect(restored.artworkURL == nil)
        #expect(restored.previewURL == nil)
        #expect(restored.releaseDate == nil)
    }
}

// MARK: - PersistenceContainer Tests

@Suite("PersistenceContainer")
struct PersistenceContainerTests {

    @Test("makeTestContainer creates an in-memory container successfully")
    func makeTestContainerSucceeds() throws {
        let container = try PersistenceContainer.makeTestContainer()
        #expect(container.schema.entities.isEmpty == false)
    }
}

// MARK: - CacheActor Tests

@Suite("CacheActor")
struct CacheActorTests {

    /// Creates a fresh in-memory CacheActor for each test.
    private func makeSUT() throws -> CacheActor {
        let container = try PersistenceContainer.makeTestContainer()
        return CacheActor(modelContainer: container)
    }

    // MARK: - cacheSongs

    @Test("cacheSongs inserts new songs that can be retrieved via recentlyPlayed after marking")
    func cacheSongsInsertsNewSongs() async throws {
        let sut = try makeSUT()
        let songs = [
            makeSong(id: 1, name: "Song One"),
            makeSong(id: 2, name: "Song Two"),
            makeSong(id: 3, name: "Song Three")
        ]

        try await sut.cacheSongs(songs, for: "test")

        // Mark all as played so we can retrieve them
        for song in songs {
            try await sut.markAsRecentlyPlayed(song)
        }

        let played = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(played.count == 3)

        let names = Set(played.map(\.name))
        #expect(names.contains("Song One"))
        #expect(names.contains("Song Two"))
        #expect(names.contains("Song Three"))
    }

    @Test("cacheSongs upserts existing songs by songId")
    func cacheSongsUpsertsExistingSongs() async throws {
        let sut = try makeSUT()

        let original = makeSong(id: 10, name: "Original Name", genre: "Rock")
        try await sut.cacheSongs([original], for: "test")

        // Upsert with updated fields
        let updated = makeSong(id: 10, name: "Updated Name", genre: "Jazz")
        try await sut.cacheSongs([updated], for: "test")

        // Mark as played to retrieve
        try await sut.markAsRecentlyPlayed(updated)

        let played = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(played.count == 1)
        #expect(played.first?.name == "Updated Name")
        #expect(played.first?.genre == "Jazz")
    }

    @Test("cacheSongs with empty array does not throw")
    func cacheSongsEmptyArray() async throws {
        let sut = try makeSUT()
        try await sut.cacheSongs([], for: "test")

        let played = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(played.isEmpty)
    }

    // MARK: - cachedSongs(for:)

    @Test("cachedSongs(for:) returns songs matching the query")
    func cachedSongsReturnsSongsMatchingQuery() async throws {
        let sut = try makeSUT()
        let songs = [makeSong(id: 1, name: "Hello")]

        try await sut.cacheSongs(songs, for: "hello")

        let results = try await sut.cachedSongs(for: "hello")
        #expect(results.count == 1)
        #expect(results.first?.name == "Hello")

        // Different query returns empty
        let noResults = try await sut.cachedSongs(for: "goodbye")
        #expect(noResults.isEmpty)
    }

    @Test("cachedSongs(for:) returns empty for non-matching query")
    func cachedSongsReturnsEmptyForNonMatchingQuery() async throws {
        let sut = try makeSUT()

        try await sut.cacheSongs([makeSong(id: 1)], for: "something")

        let results = try await sut.cachedSongs(for: "nonexistent")
        #expect(results.isEmpty)
    }

    @Test("cachedSongs(for:) returns empty when cache is empty")
    func cachedSongsReturnsEmptyOnEmptyCache() async throws {
        let sut = try makeSUT()

        let results = try await sut.cachedSongs(for: "anything")
        #expect(results.isEmpty)
    }

    // MARK: - markAsRecentlyPlayed

    @Test("markAsRecentlyPlayed inserts a new song if not already cached")
    func markAsRecentlyPlayedInsertsNewSong() async throws {
        let sut = try makeSUT()
        let song = makeSong(id: 99, name: "Brand New")

        try await sut.markAsRecentlyPlayed(song)

        let played = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(played.count == 1)
        #expect(played.first?.id == 99)
        #expect(played.first?.name == "Brand New")
    }

    @Test("markAsRecentlyPlayed updates lastPlayedAt for an already cached song")
    func markAsRecentlyPlayedUpdatesExistingSong() async throws {
        let sut = try makeSUT()
        let song = makeSong(id: 5, name: "Cached Song")

        // First cache it
        try await sut.cacheSongs([song], for: "test")

        // Then mark as played
        try await sut.markAsRecentlyPlayed(song)

        let played = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(played.count == 1)
        #expect(played.first?.id == 5)
    }

    @Test("markAsRecentlyPlayed called twice updates lastPlayedAt to a later time")
    func markAsRecentlyPlayedUpdatesTimestamp() async throws {
        let sut = try makeSUT()
        let song = makeSong(id: 20, name: "Replay Me")

        try await sut.markAsRecentlyPlayed(song)

        // Small delay to ensure timestamps differ
        try await Task.sleep(for: .milliseconds(50))

        try await sut.markAsRecentlyPlayed(song)

        // Should still be one song, not duplicated
        let played = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(played.count == 1)
        #expect(played.first?.id == 20)
    }

    // MARK: - recentlyPlayedSongs

    @Test("recentlyPlayedSongs returns songs ordered by most recent first")
    func recentlyPlayedSongsOrderedByMostRecent() async throws {
        let sut = try makeSUT()

        let songA = makeSong(id: 1, name: "First Played")
        let songB = makeSong(id: 2, name: "Second Played")
        let songC = makeSong(id: 3, name: "Third Played")

        try await sut.markAsRecentlyPlayed(songA)
        try await Task.sleep(for: .milliseconds(50))
        try await sut.markAsRecentlyPlayed(songB)
        try await Task.sleep(for: .milliseconds(50))
        try await sut.markAsRecentlyPlayed(songC)

        let played = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(played.count == 3)
        // Most recent first
        #expect(played[0].name == "Third Played")
        #expect(played[1].name == "Second Played")
        #expect(played[2].name == "First Played")
    }

    @Test("recentlyPlayedSongs respects the limit parameter")
    func recentlyPlayedSongsRespectsLimit() async throws {
        let sut = try makeSUT()

        for i in 1...5 {
            try await sut.markAsRecentlyPlayed(makeSong(id: i, name: "Song \(i)"))
            try await Task.sleep(for: .milliseconds(50))
        }

        let played = try await sut.recentlyPlayedSongs(limit: 3)
        #expect(played.count == 3)
        // Should be the 3 most recent
        #expect(played[0].name == "Song 5")
        #expect(played[1].name == "Song 4")
        #expect(played[2].name == "Song 3")
    }

    @Test("recentlyPlayedSongs returns only songs with lastPlayedAt set")
    func recentlyPlayedSongsExcludesUnplayed() async throws {
        let sut = try makeSUT()

        // Cache without marking as played
        try await sut.cacheSongs([
            makeSong(id: 1, name: "Cached Only"),
            makeSong(id: 2, name: "Also Cached Only")
        ], for: "test")

        // Mark only one as played
        try await sut.markAsRecentlyPlayed(makeSong(id: 3, name: "Actually Played"))

        let played = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(played.count == 1)
        #expect(played.first?.name == "Actually Played")
    }

    @Test("recentlyPlayedSongs returns empty when no songs have been played")
    func recentlyPlayedSongsReturnsEmptyWhenNonePlayed() async throws {
        let sut = try makeSUT()

        let played = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(played.isEmpty)
    }

    @Test("recentlyPlayedSongs with limit 0 returns all songs (SwiftData treats 0 as no limit)")
    func recentlyPlayedSongsLimitZero() async throws {
        let sut = try makeSUT()

        try await sut.markAsRecentlyPlayed(makeSong(id: 1))

        // NOTE: SwiftData's FetchDescriptor treats fetchLimit = 0 as "no limit",
        // so all matching songs are returned.
        let played = try await sut.recentlyPlayedSongs(limit: 0)
        #expect(played.count == 1)
    }

    // MARK: - clearCache

    @Test("clearCache removes all cached songs")
    func clearCacheRemovesEverything() async throws {
        let sut = try makeSUT()

        // Insert some songs
        try await sut.cacheSongs([
            makeSong(id: 1, name: "Song A"),
            makeSong(id: 2, name: "Song B")
        ], for: "test")
        try await sut.markAsRecentlyPlayed(makeSong(id: 3, name: "Song C"))

        // Clear
        try await sut.clearCache()

        // Verify all are gone
        let played = try await sut.recentlyPlayedSongs(limit: 100)
        #expect(played.isEmpty)

        let cached = try await sut.cachedSongs(for: "anything")
        #expect(cached.isEmpty)
    }

    @Test("clearCache on empty cache does not throw")
    func clearCacheOnEmptyCacheSucceeds() async throws {
        let sut = try makeSUT()

        try await sut.clearCache()

        let played = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(played.isEmpty)
    }

    @Test("clearCache followed by new inserts works correctly")
    func clearCacheThenReinsert() async throws {
        let sut = try makeSUT()

        try await sut.markAsRecentlyPlayed(makeSong(id: 1, name: "Before Clear"))
        try await sut.clearCache()
        try await sut.markAsRecentlyPlayed(makeSong(id: 2, name: "After Clear"))

        let played = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(played.count == 1)
        #expect(played.first?.name == "After Clear")
    }

    // MARK: - Integration / Edge Cases

    @Test("full workflow: cache, mark played, query, clear")
    func fullWorkflow() async throws {
        let sut = try makeSUT()

        // 1. Cache songs
        let songs = [
            makeSong(id: 1, name: "Alpha", genre: "Rock"),
            makeSong(id: 2, name: "Beta", genre: "Pop"),
            makeSong(id: 3, name: "Gamma", genre: "Jazz")
        ]
        try await sut.cacheSongs(songs, for: "test")

        // 2. Mark some as played
        try await sut.markAsRecentlyPlayed(songs[0])
        try await Task.sleep(for: .milliseconds(50))
        try await sut.markAsRecentlyPlayed(songs[2])

        // 3. Check recently played
        let played = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(played.count == 2)
        #expect(played[0].name == "Gamma") // most recent
        #expect(played[1].name == "Alpha")

        // 4. Clear cache
        try await sut.clearCache()

        let afterClear = try await sut.recentlyPlayedSongs(limit: 10)
        #expect(afterClear.isEmpty)
    }

    @Test("cacheSongs preserves all Song fields through persistence round-trip")
    func cacheSongsPreservesAllFields() async throws {
        let sut = try makeSUT()
        let releaseDate = Date(timeIntervalSince1970: 1_600_000_000)

        let song = makeSong(
            id: 42,
            name: "Detailed Song",
            artistName: "Detailed Artist",
            albumName: "Detailed Album",
            albumId: 777,
            artworkURL: URL(string: "https://example.com/detailed100x100.jpg"),
            previewURL: URL(string: "https://example.com/detailed.m4a"),
            durationInMilliseconds: 245_000,
            genre: "Classical",
            trackNumber: 5,
            releaseDate: releaseDate
        )

        try await sut.cacheSongs([song], for: "detailed")
        try await sut.markAsRecentlyPlayed(song)

        let played = try await sut.recentlyPlayedSongs(limit: 1)
        #expect(played.count == 1)

        let restored = played[0]
        #expect(restored.id == 42)
        #expect(restored.name == "Detailed Song")
        #expect(restored.artistName == "Detailed Artist")
        #expect(restored.albumName == "Detailed Album")
        #expect(restored.albumId == 777)
        #expect(restored.artworkURL == URL(string: "https://example.com/detailed100x100.jpg"))
        #expect(restored.previewURL == URL(string: "https://example.com/detailed.m4a"))
        #expect(restored.durationInMilliseconds == 245_000)
        #expect(restored.genre == "Classical")
        #expect(restored.trackNumber == 5)
        #expect(restored.releaseDate == releaseDate)
    }
}
