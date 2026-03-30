import Foundation
import MiryamCore

/// ViewModel for the Songs (Home) screen.
@Observable
@MainActor
public final class SongsViewModel {
    // MARK: - Published State

    public var songs: [Song] = []
    public var recentlyPlayed: [Song] = []
    public var searchQuery: String = ""
    public var isLoading = false
    public var isLoadingMore = false
    public var error: AppError?
    public var hasMorePages = true

    // MARK: - Private

    private let songRepository: any SongRepositoryProtocol
    private let cacheRepository: any CacheRepositoryProtocol
    private var pagination = Pagination(limit: Constants.Search.pageLimit)
    private var searchTask: Task<Void, Never>?

    public init(
        songRepository: any SongRepositoryProtocol,
        cacheRepository: any CacheRepositoryProtocol
    ) {
        self.songRepository = songRepository
        self.cacheRepository = cacheRepository
    }

    /// Load recently played songs on first appearance.
    public func loadRecentlyPlayed() async {
        do {
            recentlyPlayed = try await cacheRepository.recentlyPlayedSongs(limit: Constants.Search.recentlyPlayedLimit)
        } catch {
            // Silently fail -- recently played is non-critical
        }
    }

    /// Search songs with debounce. Call this when searchQuery changes.
    public func search() {
        searchTask?.cancel()

        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            songs = []
            error = nil
            pagination.reset()
            return
        }

        searchTask = Task {
            // Debounce 300ms
            try? await Task.sleep(for: .milliseconds(Constants.Search.debounceMilliseconds))
            guard !Task.isCancelled else { return }

            pagination.reset()
            isLoading = true
            error = nil

            do {
                let result = try await songRepository.searchSongs(
                    query: searchQuery,
                    limit: pagination.limit,
                    offset: pagination.offset
                )
                guard !Task.isCancelled else { return }
                songs = result.songs
                pagination.advance(resultCount: result.songs.count)
                hasMorePages = pagination.hasMorePages

                // Cache results with the search query for offline fallback
                try? await cacheRepository.cacheSongs(result.songs, for: searchQuery)
            } catch let appError as AppError {
                guard !Task.isCancelled else { return }
                // Try cache on network error
                if case .noInternetConnection = appError {
                    let cached = try? await cacheRepository.cachedSongs(for: searchQuery)
                    if let cached, !cached.isEmpty {
                        songs = cached
                        error = .noInternetConnection
                        return
                    }
                }
                error = appError
            } catch {
                guard !Task.isCancelled else { return }
                self.error = .unknown(error.localizedDescription)
            }

            isLoading = false
        }
    }

    /// Load next page of results.
    public func loadMore() async {
        guard !isLoadingMore, hasMorePages, !searchQuery.isEmpty else { return }

        isLoadingMore = true

        do {
            let result = try await songRepository.searchSongs(
                query: searchQuery,
                limit: pagination.limit,
                offset: pagination.offset
            )
            songs.append(contentsOf: result.songs)
            pagination.advance(resultCount: result.songs.count)
            hasMorePages = pagination.hasMorePages

            try? await cacheRepository.cacheSongs(result.songs, for: searchQuery)
        } catch {
            // Silently fail on pagination errors -- user still has current results
        }

        isLoadingMore = false
    }

    /// Pull-to-refresh: re-execute current search from scratch.
    public func refresh() async {
        guard !searchQuery.isEmpty else {
            await loadRecentlyPlayed()
            return
        }

        pagination.reset()
        error = nil

        do {
            let result = try await songRepository.searchSongs(
                query: searchQuery,
                limit: pagination.limit,
                offset: pagination.offset
            )
            songs = result.songs
            pagination.advance(resultCount: result.songs.count)
            hasMorePages = pagination.hasMorePages
        } catch {
            // Keep existing results on refresh failure
        }
    }
}
