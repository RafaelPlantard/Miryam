import Testing
import Foundation
@testable import MiryamFeatures
import MiryamCore

// MARK: - Test Helpers

func makeSong(id: Int = 1, name: String = "Test Song") -> Song {
    Song(
        id: id,
        name: name,
        artistName: "Artist",
        albumName: "Album",
        albumId: 100,
        artworkURL: URL(string: "https://example.com/100x100.jpg"),
        previewURL: URL(string: "https://example.com/preview.m4a"),
        durationInMilliseconds: 30000,
        genre: "Pop",
        trackNumber: 1,
        releaseDate: nil
    )
}

func makeAlbum(id: Int = 100, name: String = "Test Album") -> Album {
    Album(
        id: id,
        name: name,
        artistName: "Artist",
        artworkURL: URL(string: "https://example.com/100x100.jpg"),
        trackCount: 10,
        releaseDate: nil,
        genre: "Pop"
    )
}

// MARK: - Mock Implementations

actor MockSongRepository: SongRepositoryProtocol {
    var searchResult: SearchResult = SearchResult(songs: [], totalCount: 0)
    var albumSongs: [Song] = []
    var shouldThrow: AppError?
    var searchCallCount = 0

    func setSearchResult(_ result: SearchResult) { searchResult = result }
    func setAlbumSongs(_ songs: [Song]) { albumSongs = songs }
    func setShouldThrow(_ error: AppError?) { shouldThrow = error }
    func getSearchCallCount() -> Int { searchCallCount }

    func searchSongs(query: String, limit: Int, offset: Int) async throws -> SearchResult {
        searchCallCount += 1
        if let error = shouldThrow { throw error }
        return searchResult
    }

    func fetchAlbumSongs(albumId: Int) async throws -> [Song] {
        if let error = shouldThrow { throw error }
        return albumSongs
    }
}

actor MockCacheRepository: CacheRepositoryProtocol {
    var cachedSongsResult: [Song] = []
    var recentlyPlayedResult: [Song] = []
    var markedAsPlayed: [Song] = []
    var cachedSongsCalls: [[Song]] = []

    func setCachedSongsResult(_ songs: [Song]) { cachedSongsResult = songs }
    func setRecentlyPlayedResult(_ songs: [Song]) { recentlyPlayedResult = songs }
    func getMarkedAsPlayed() -> [Song] { markedAsPlayed }
    func getCachedSongsCalls() -> [[Song]] { cachedSongsCalls }

    func cacheSongs(_ songs: [Song], for query: String) async throws {
        cachedSongsCalls.append(songs)
    }

    func cachedSongs(for query: String) async throws -> [Song] {
        cachedSongsResult
    }

    func markAsRecentlyPlayed(_ song: Song) async throws {
        markedAsPlayed.append(song)
    }

    func recentlyPlayedSongs(limit: Int) async throws -> [Song] {
        Array(recentlyPlayedResult.prefix(limit))
    }

    func clearCache() async throws {
        cachedSongsResult = []
        recentlyPlayedResult = []
    }
}

actor MockPlayer: PlayerProtocol {
    var playedSongs: [Song] = []
    var isPaused = false
    var isResumed = false
    var isStopped = false
    var seekProgress: Double?
    var skipForwardSeconds: TimeInterval?
    var skipBackwardSeconds: TimeInterval?
    var shouldThrow: AppError?

    private let continuation: AsyncStream<PlaybackState>.Continuation
    private let _stateStream: AsyncStream<PlaybackState>

    nonisolated var stateStream: AsyncStream<PlaybackState> { _stateStream }

    init() {
        let (stream, continuation) = AsyncStream<PlaybackState>.makeStream()
        self._stateStream = stream
        self.continuation = continuation
    }

    func emitState(_ state: PlaybackState) { continuation.yield(state) }
    func setShouldThrow(_ error: AppError?) { shouldThrow = error }
    func getPlayedSongs() -> [Song] { playedSongs }
    func getIsPaused() -> Bool { isPaused }
    func getIsResumed() -> Bool { isResumed }
    func getIsStopped() -> Bool { isStopped }
    func getSeekProgress() -> Double? { seekProgress }
    func getSkipForwardSeconds() -> TimeInterval? { skipForwardSeconds }
    func getSkipBackwardSeconds() -> TimeInterval? { skipBackwardSeconds }

    func play(_ song: Song) async throws {
        if let error = shouldThrow { throw error }
        playedSongs.append(song)
    }

    func pause() async { isPaused = true }
    func resume() async { isResumed = true }
    func stop() async { isStopped = true }
    func seek(to progress: Double) async { seekProgress = progress }
    func skipForward(seconds: TimeInterval) async { skipForwardSeconds = seconds }
    func skipBackward(seconds: TimeInterval) async { skipBackwardSeconds = seconds }
    func setRepeatMode(_ mode: RepeatMode) async {}
}

// MARK: - SongsViewModel Tests

@Suite("SongsViewModel")
struct SongsViewModelTests {

    @Test("init sets correct defaults")
    @MainActor
    func initSetsDefaults() {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)

        #expect(viewModel.songs.isEmpty)
        #expect(viewModel.recentlyPlayed.isEmpty)
        #expect(viewModel.searchQuery == "")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isLoadingMore == false)
        #expect(viewModel.error == nil)
        #expect(viewModel.hasMorePages == true)
    }

    @Test("loadRecentlyPlayed populates recentlyPlayed from cacheRepository")
    @MainActor
    func loadRecentlyPlayedPopulatesFromCache() async {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        let songs = [makeSong(id: 1, name: "Recent 1"), makeSong(id: 2, name: "Recent 2")]
        await cacheRepo.setRecentlyPlayedResult(songs)

        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)
        await viewModel.loadRecentlyPlayed()

        #expect(viewModel.recentlyPlayed.count == 2)
        #expect(viewModel.recentlyPlayed[0].name == "Recent 1")
        #expect(viewModel.recentlyPlayed[1].name == "Recent 2")
    }

    @Test("search with empty query clears songs")
    @MainActor
    func searchWithEmptyQueryClearsSongs() async {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)

        // Populate songs first via a valid search
        let songs = [makeSong(id: 1)]
        await songRepo.setSearchResult(SearchResult(songs: songs, totalCount: 1))
        viewModel.searchQuery = "test"
        viewModel.search()
        try? await Task.sleep(for: .milliseconds(500))

        #expect(!viewModel.songs.isEmpty)

        // Now search with empty query
        viewModel.searchQuery = ""
        viewModel.search()

        #expect(viewModel.songs.isEmpty)
        #expect(viewModel.error == nil)
    }

    @Test("search with whitespace-only query clears songs")
    @MainActor
    func searchWithWhitespaceQueryClearsSongs() {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)

        viewModel.searchQuery = "   "
        viewModel.search()

        #expect(viewModel.songs.isEmpty)
        #expect(viewModel.error == nil)
    }

    @Test("search with valid query populates songs from songRepository")
    @MainActor
    func searchWithValidQueryPopulatesSongs() async throws {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        let songs = [makeSong(id: 1, name: "Found Song"), makeSong(id: 2, name: "Another")]
        await songRepo.setSearchResult(SearchResult(songs: songs, totalCount: 2))

        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)
        viewModel.searchQuery = "test"
        viewModel.search()

        // Wait for debounce (300ms) + some execution time
        try await Task.sleep(for: .milliseconds(500))

        #expect(viewModel.songs.count == 2)
        #expect(viewModel.songs[0].name == "Found Song")
        #expect(viewModel.songs[1].name == "Another")
        #expect(viewModel.isLoading == false)
    }

    @Test("search caches results via cacheRepository")
    @MainActor
    func searchCachesResults() async throws {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        let songs = [makeSong(id: 1), makeSong(id: 2)]
        await songRepo.setSearchResult(SearchResult(songs: songs, totalCount: 2))

        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)
        viewModel.searchQuery = "cache test"
        viewModel.search()

        try await Task.sleep(for: .milliseconds(500))

        let cachedCalls = await cacheRepo.getCachedSongsCalls()
        #expect(cachedCalls.count == 1)
        #expect(cachedCalls[0].count == 2)
    }

    @Test("search updates hasMorePages based on pagination")
    @MainActor
    func searchUpdatesHasMorePages() async throws {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()

        // Return fewer songs than the limit (25), so hasMorePages should be false
        let songs = [makeSong(id: 1)]
        await songRepo.setSearchResult(SearchResult(songs: songs, totalCount: 1))

        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)
        viewModel.searchQuery = "few results"
        viewModel.search()

        try await Task.sleep(for: .milliseconds(500))

        #expect(viewModel.hasMorePages == false)
    }

    @Test("search sets error on failure")
    @MainActor
    func searchSetsErrorOnFailure() async throws {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        await songRepo.setShouldThrow(.networkError("Connection failed"))

        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)
        viewModel.searchQuery = "fail"
        viewModel.search()

        try await Task.sleep(for: .milliseconds(500))

        #expect(viewModel.error == .networkError("Connection failed"))
        #expect(viewModel.songs.isEmpty)
    }

    @Test("search debounces multiple rapid calls")
    @MainActor
    func searchDebounces() async throws {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        let songs = [makeSong(id: 1)]
        await songRepo.setSearchResult(SearchResult(songs: songs, totalCount: 1))

        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)

        // Rapid-fire searches -- only the last should execute
        viewModel.searchQuery = "a"
        viewModel.search()
        viewModel.searchQuery = "ab"
        viewModel.search()
        viewModel.searchQuery = "abc"
        viewModel.search()

        try await Task.sleep(for: .milliseconds(500))

        let callCount = await songRepo.getSearchCallCount()
        #expect(callCount == 1)
    }

    @Test("loadMore appends next page results")
    @MainActor
    func loadMoreAppendsResults() async throws {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()

        // First page: 25 songs so hasMorePages stays true
        let firstPage = (1...25).map { makeSong(id: $0, name: "Song \($0)") }
        await songRepo.setSearchResult(SearchResult(songs: firstPage, totalCount: 50))

        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)
        viewModel.searchQuery = "load more"
        viewModel.search()

        try await Task.sleep(for: .milliseconds(500))

        #expect(viewModel.songs.count == 25)
        #expect(viewModel.hasMorePages == true)

        // Second page
        let secondPage = (26...30).map { makeSong(id: $0, name: "Song \($0)") }
        await songRepo.setSearchResult(SearchResult(songs: secondPage, totalCount: 50))

        viewModel.loadMore()
        try? await Task.sleep(for: .milliseconds(500))

        #expect(viewModel.songs.count == 30)
        #expect(viewModel.hasMorePages == false) // 5 < 25 limit
    }

    @Test("loadMore does not load when hasMorePages is false")
    @MainActor
    func loadMoreDoesNotLoadWhenNoMorePages() async throws {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()

        // Return fewer than limit so hasMorePages is false
        let songs = [makeSong(id: 1)]
        await songRepo.setSearchResult(SearchResult(songs: songs, totalCount: 1))

        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)
        viewModel.searchQuery = "no more"
        viewModel.search()

        try await Task.sleep(for: .milliseconds(500))

        #expect(viewModel.hasMorePages == false)

        let countBefore = await songRepo.getSearchCallCount()

        viewModel.loadMore()
        try? await Task.sleep(for: .milliseconds(500))

        let countAfter = await songRepo.getSearchCallCount()
        #expect(countAfter == countBefore) // No additional call
    }

    @Test("loadMore does not load when searchQuery is empty")
    @MainActor
    func loadMoreDoesNotLoadWhenQueryEmpty() async {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)

        viewModel.loadMore()
        try? await Task.sleep(for: .milliseconds(500))

        let callCount = await songRepo.getSearchCallCount()
        #expect(callCount == 0)
    }

    @Test("refresh re-executes current search")
    @MainActor
    func refreshReExecutesSearch() async throws {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()

        let initialSongs = [makeSong(id: 1, name: "Initial")]
        await songRepo.setSearchResult(SearchResult(songs: initialSongs, totalCount: 1))

        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)
        viewModel.searchQuery = "refresh"
        viewModel.search()

        try await Task.sleep(for: .milliseconds(500))

        #expect(viewModel.songs.count == 1)
        #expect(viewModel.songs[0].name == "Initial")

        // Now update what the repo returns and refresh
        let refreshedSongs = [makeSong(id: 2, name: "Refreshed"), makeSong(id: 3, name: "New")]
        await songRepo.setSearchResult(SearchResult(songs: refreshedSongs, totalCount: 2))

        await viewModel.refresh()

        #expect(viewModel.songs.count == 2)
        #expect(viewModel.songs[0].name == "Refreshed")
    }

    @Test("refresh with empty query loads recently played")
    @MainActor
    func refreshWithEmptyQueryLoadsRecentlyPlayed() async {
        let songRepo = MockSongRepository()
        let cacheRepo = MockCacheRepository()
        let recent = [makeSong(id: 5, name: "Recent")]
        await cacheRepo.setRecentlyPlayedResult(recent)

        let viewModel = SongsViewModel(songRepository: songRepo, cacheRepository: cacheRepo)
        viewModel.searchQuery = ""

        await viewModel.refresh()

        #expect(viewModel.recentlyPlayed.count == 1)
        #expect(viewModel.recentlyPlayed[0].name == "Recent")
    }
}

// MARK: - AlbumViewModel Tests

@Suite("AlbumViewModel")
struct AlbumViewModelTests {

    @Test("init stores album correctly")
    @MainActor
    func initStoresAlbum() {
        let album = makeAlbum(id: 42, name: "My Album")
        let songRepo = MockSongRepository()
        let viewModel = AlbumViewModel(album: album, songRepository: songRepo)

        #expect(viewModel.album.id == 42)
        #expect(viewModel.album.name == "My Album")
        #expect(viewModel.songs.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    @Test("loadSongs fetches songs from repository")
    @MainActor
    func loadSongsFetchesSongs() async {
        let album = makeAlbum(id: 100)
        let songRepo = MockSongRepository()
        let songs = [
            makeSong(id: 1, name: "Track 1"),
            makeSong(id: 2, name: "Track 2"),
            makeSong(id: 3, name: "Track 3")
        ]
        await songRepo.setAlbumSongs(songs)

        let viewModel = AlbumViewModel(album: album, songRepository: songRepo)
        await viewModel.loadSongs()

        #expect(viewModel.songs.count == 3)
        #expect(viewModel.songs[0].name == "Track 1")
        #expect(viewModel.songs[2].name == "Track 3")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    @Test("loadSongs sets error on failure")
    @MainActor
    func loadSongsSetsError() async {
        let album = makeAlbum()
        let songRepo = MockSongRepository()
        await songRepo.setShouldThrow(.networkError("No network"))

        let viewModel = AlbumViewModel(album: album, songRepository: songRepo)
        await viewModel.loadSongs()

        #expect(viewModel.songs.isEmpty)
        #expect(viewModel.error == .networkError("No network"))
        #expect(viewModel.isLoading == false)
    }

    @Test("loadSongs does not re-fetch if songs already loaded")
    @MainActor
    func loadSongsDoesNotRefetch() async {
        let album = makeAlbum(id: 100)
        let songRepo = MockSongRepository()
        let songs = [makeSong(id: 1)]
        await songRepo.setAlbumSongs(songs)

        let viewModel = AlbumViewModel(album: album, songRepository: songRepo)
        await viewModel.loadSongs()

        #expect(viewModel.songs.count == 1)

        // Change what repo would return
        await songRepo.setAlbumSongs([makeSong(id: 2), makeSong(id: 3)])

        // Second call should be a no-op because songs are already loaded
        await viewModel.loadSongs()

        #expect(viewModel.songs.count == 1)
        #expect(viewModel.songs[0].id == 1)
    }

    @Test("loadSongs sets unknown error for non-AppError throws")
    @MainActor
    func loadSongsSetsUnknownError() async {
        let album = makeAlbum()
        let songRepo = MockSongRepository()
        await songRepo.setShouldThrow(.unknown("Something broke"))

        let viewModel = AlbumViewModel(album: album, songRepository: songRepo)
        await viewModel.loadSongs()

        #expect(viewModel.error == .unknown("Something broke"))
    }
}

// MARK: - Router Tests

@Suite("Router")
struct RouterTests {

    @Test("navigate(to:) appends to path")
    @MainActor
    func navigateAppendsToPath() {
        let router = Router()
        let song = makeSong(id: 1)

        router.navigate(to: .player(song))

        #expect(!router.path.isEmpty)
        #expect(router.path.count == 1)
    }

    @Test("navigate(to:) appends multiple routes")
    @MainActor
    func navigateAppendsMultipleRoutes() {
        let router = Router()
        let song = makeSong(id: 1)
        let album = makeAlbum(id: 100)

        router.navigate(to: .player(song))
        router.navigate(to: .album(album))

        #expect(router.path.count == 2)
    }

    @Test("presentSheet sets presentedSheet")
    @MainActor
    func presentSheetSetsPresentedSheet() {
        let router = Router()
        let song = makeSong(id: 42)

        router.presentSheet(.moreOptions(song))

        #expect(router.presentedSheet != nil)
        if case .moreOptions(let presentedSong) = router.presentedSheet {
            #expect(presentedSong.id == 42)
        } else {
            Issue.record("Expected moreOptions sheet")
        }
    }

    @Test("dismissSheet clears presentedSheet")
    @MainActor
    func dismissSheetClearsPresentedSheet() {
        let router = Router()
        let song = makeSong()

        router.presentSheet(.moreOptions(song))
        #expect(router.presentedSheet != nil)

        router.dismissSheet()
        #expect(router.presentedSheet == nil)
    }

    @Test("popToRoot resets path")
    @MainActor
    func popToRootResetsPath() {
        let router = Router()
        let song = makeSong()
        let album = makeAlbum()

        router.navigate(to: .player(song))
        router.navigate(to: .album(album))
        #expect(router.path.count == 2)

        router.popToRoot()
        #expect(router.path.isEmpty)
    }

    @Test("pop removes last item from path")
    @MainActor
    func popRemovesLast() {
        let router = Router()
        let song = makeSong(id: 1)
        let album = makeAlbum(id: 200)

        router.navigate(to: .player(song))
        router.navigate(to: .album(album))
        #expect(router.path.count == 2)

        router.pop()
        #expect(router.path.count == 1)
    }

    @Test("pop on empty path does nothing")
    @MainActor
    func popOnEmptyPathDoesNothing() {
        let router = Router()
        #expect(router.path.isEmpty)

        router.pop()
        #expect(router.path.isEmpty)
    }

    @Test("init starts with empty path and no sheet")
    @MainActor
    func initDefaults() {
        let router = Router()

        #expect(router.path.isEmpty)
        #expect(router.presentedSheet == nil)
    }
}

// MARK: - PlayerViewModel Tests

@Suite("PlayerViewModel")
struct PlayerViewModelTests {

    @Test("init sets correct defaults")
    @MainActor
    func initSetsDefaults() {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)

        #expect(viewModel.currentSong == nil)
        #expect(viewModel.isPlaying == false)
        #expect(viewModel.error == nil)
    }

    @Test("play sets currentSong and calls player")
    @MainActor
    func playSetsCurrentSong() async {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)
        let song = makeSong(id: 1, name: "Play Me")

        await viewModel.play(song)

        #expect(viewModel.currentSong?.id == 1)
        #expect(viewModel.currentSong?.name == "Play Me")
        #expect(viewModel.error == nil)

        let playedSongs = await player.getPlayedSongs()
        #expect(playedSongs.count == 1)
        #expect(playedSongs[0].id == 1)
    }

    @Test("play marks song as recently played in cache")
    @MainActor
    func playMarksSongAsRecentlyPlayed() async {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)
        let song = makeSong(id: 7)

        await viewModel.play(song)

        let marked = await cacheRepo.getMarkedAsPlayed()
        #expect(marked.count == 1)
        #expect(marked[0].id == 7)
    }

    @Test("play sets error on failure")
    @MainActor
    func playSetsErrorOnFailure() async {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        await player.setShouldThrow(.playbackFailed("Cannot play"))

        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)
        let song = makeSong()

        await viewModel.play(song)

        #expect(viewModel.error == .playbackFailed("Cannot play"))
        #expect(viewModel.isPlaying == false)
    }

    @Test("togglePlayPause pauses when playing")
    @MainActor
    func togglePlayPausePausesWhenPlaying() async {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)

        // Set isPlaying to true by emitting a playing state
        viewModel.isPlaying = true

        await viewModel.togglePlayPause()

        let isPaused = await player.getIsPaused()
        #expect(isPaused == true)
    }

    @Test("togglePlayPause resumes when paused")
    @MainActor
    func togglePlayPauseResumesWhenPaused() async {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)

        // isPlaying defaults to false
        await viewModel.togglePlayPause()

        let isResumed = await player.getIsResumed()
        #expect(isResumed == true)
    }

    @Test("seek forwards to player")
    @MainActor
    func seekForwardsToPlayer() async {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)

        await viewModel.seek(to: 0.75)

        let progress = await player.getSeekProgress()
        #expect(progress == 0.75)
    }

    @Test("skipForward calls player with 15 seconds")
    @MainActor
    func skipForwardCallsPlayer() async {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)

        await viewModel.skipForward()

        let seconds = await player.getSkipForwardSeconds()
        #expect(seconds == 15)
    }

    @Test("skipBackward calls player with 15 seconds")
    @MainActor
    func skipBackwardCallsPlayer() async {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)

        await viewModel.skipBackward()

        let seconds = await player.getSkipBackwardSeconds()
        #expect(seconds == 15)
    }

    @Test("stop calls player and clears currentSong")
    @MainActor
    func stopClearsCurrentSong() async {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)
        let song = makeSong()

        await viewModel.play(song)
        #expect(viewModel.currentSong != nil)

        await viewModel.stop()

        #expect(viewModel.currentSong == nil)
        let isStopped = await player.getIsStopped()
        #expect(isStopped == true)
    }

    @Test("observes playback state stream for playing status")
    @MainActor
    func observesPlayingState() async throws {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)
        let song = makeSong(id: 10, name: "Streaming")

        let playingState = PlaybackState(
            status: .playing,
            currentSong: song,
            currentTime: 5.0,
            duration: 30.0,
            progress: 5.0 / 30.0
        )

        await player.emitState(playingState)

        // Give the observation task time to process
        try await Task.sleep(for: .milliseconds(100))

        #expect(viewModel.isPlaying == true)
        #expect(viewModel.currentSong?.id == 10)
        #expect(viewModel.error == nil)
    }

    @Test("observes playback state stream for paused status")
    @MainActor
    func observesPausedState() async throws {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)

        let pausedState = PlaybackState(
            status: .paused,
            currentSong: makeSong(),
            currentTime: 10.0,
            duration: 30.0,
            progress: 10.0 / 30.0
        )

        await player.emitState(pausedState)

        try await Task.sleep(for: .milliseconds(100))

        #expect(viewModel.isPlaying == false)
    }

    @Test("observes playback state stream for failed status")
    @MainActor
    func observesFailedState() async throws {
        let player = MockPlayer()
        let cacheRepo = MockCacheRepository()
        let viewModel = PlayerViewModel(player: player, cacheRepository: cacheRepo)

        let failedState = PlaybackState(
            status: .failed(.playbackFailed("Decode error")),
            currentSong: nil
        )

        await player.emitState(failedState)

        try await Task.sleep(for: .milliseconds(100))

        #expect(viewModel.isPlaying == false)
        #expect(viewModel.error == .playbackFailed("Decode error"))
    }
}
