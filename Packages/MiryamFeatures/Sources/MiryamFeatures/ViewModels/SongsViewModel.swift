import Foundation
import MiryamCore
import os

private let logger = Logger(subsystem: "io.swift-yah.miryam", category: "Search")

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
    private var loadMoreTask: Task<Void, Never>?

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
            logger.error("Failed to load recently played: \(error)")
        }
    }

    /// Search songs with debounce. Call this when searchQuery changes.
    public func search() {
        searchTask?.cancel()
        loadMoreTask?.cancel()

        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            songs = []
            error = nil
            pagination.reset()
            return
        }

        let query = searchQuery
        logger.debug("Search: \(query)")

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(Constants.Search.debounceMilliseconds))
            guard !Task.isCancelled else { return }

            pagination.reset()
            isLoading = true
            error = nil

            do {
                let result = try await songRepository.searchSongs(
                    query: query,
                    limit: pagination.limit,
                    offset: pagination.offset
                )
                guard !Task.isCancelled else { return }
                songs = result.songs
                pagination.advance(resultCount: result.songs.count)
                hasMorePages = pagination.hasMorePages

                logger.info("Search '\(query)': \(result.songs.count) results")

                // Cache results for offline fallback
                do {
                    try await cacheRepository.cacheSongs(result.songs, for: query)
                } catch {
                    logger.warning("Cache write failed: \(error)")
                }
            } catch let appError as AppError {
                guard !Task.isCancelled else { return }
                if case .noInternetConnection = appError {
                    let cached = try? await cacheRepository.cachedSongs(for: query)
                    if let cached, !cached.isEmpty {
                        songs = cached
                        error = .noInternetConnection
                        logger.info("Serving \(cached.count) cached results for '\(query)'")
                        isLoading = false
                        return
                    }
                }
                error = appError
                logger.error("Search failed: \(appError)")
            } catch {
                guard !Task.isCancelled else { return }
                self.error = .unknown(error.localizedDescription)
                logger.error("Search failed (unknown): \(error)")
            }

            isLoading = false
        }
    }

    /// Load next page of results.
    public func loadMore() {
        guard !isLoading, !isLoadingMore, hasMorePages, !searchQuery.isEmpty else { return }

        let query = searchQuery
        let currentOffset = pagination.offset
        logger.debug("Loading more for '\(query)' at offset \(currentOffset)")

        loadMoreTask = Task {
            isLoadingMore = true

            do {
                let result = try await songRepository.searchSongs(
                    query: query,
                    limit: pagination.limit,
                    offset: pagination.offset
                )
                guard !Task.isCancelled else {
                    isLoadingMore = false
                    return
                }
                songs.append(contentsOf: result.songs)
                pagination.advance(resultCount: result.songs.count)
                hasMorePages = pagination.hasMorePages

                logger.info("Loaded \(result.songs.count) more for '\(query)'")

                do {
                    try await cacheRepository.cacheSongs(result.songs, for: query)
                } catch {
                    logger.warning("Cache write failed during pagination: \(error)")
                }
            } catch {
                logger.error("Pagination failed: \(error)")
            }

            isLoadingMore = false
        }
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
            logger.warning("Refresh failed: \(error)")
        }
    }
}
