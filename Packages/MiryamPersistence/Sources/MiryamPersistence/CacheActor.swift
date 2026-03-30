import Foundation
import MiryamCore
import SwiftData

/// Actor-based cache using SwiftData for offline-first song storage.
@ModelActor
public actor CacheActor: CacheRepositoryProtocol {
    public func cacheSongs(_ songs: [Song], for query: String) async throws {
        do {
            for song in songs {
                let songId = song.id
                let descriptor = FetchDescriptor<CachedSong>(
                    predicate: #Predicate { $0.songId == songId }
                )
                let existing = try modelContext.fetch(descriptor)

                if let cachedSong = existing.first {
                    cachedSong.name = song.name
                    cachedSong.artistName = song.artistName
                    cachedSong.albumName = song.albumName
                    cachedSong.albumId = song.albumId
                    cachedSong.artworkURLString = song.artworkURL?.absoluteString
                    cachedSong.previewURLString = song.previewURL?.absoluteString
                    cachedSong.durationInMilliseconds = song.durationInMilliseconds
                    cachedSong.genre = song.genre
                    cachedSong.trackNumber = song.trackNumber
                    cachedSong.releaseDate = song.releaseDate
                    cachedSong.cachedAt = Date()
                    cachedSong.searchQuery = query
                } else {
                    let cached = CachedSong(from: song, query: query)
                    modelContext.insert(cached)
                }
            }
            try modelContext.save()
        } catch {
            throw AppError.cacheError(error.localizedDescription)
        }
    }

    public func cachedSongs(for query: String) async throws -> [Song] {
        do {
            let descriptor = FetchDescriptor<CachedSong>(
                predicate: #Predicate { $0.searchQuery == query },
                sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
            )
            let results = try modelContext.fetch(descriptor)
            return results.map { $0.toDomain() }
        } catch {
            throw AppError.cacheError(error.localizedDescription)
        }
    }

    public func markAsRecentlyPlayed(_ song: Song) async throws {
        do {
            let songId = song.id
            let descriptor = FetchDescriptor<CachedSong>(
                predicate: #Predicate { $0.songId == songId }
            )
            let existing = try modelContext.fetch(descriptor)

            if let cachedSong = existing.first {
                cachedSong.lastPlayedAt = Date()
            } else {
                let cached = CachedSong(from: song)
                cached.lastPlayedAt = Date()
                modelContext.insert(cached)
            }
            try modelContext.save()
        } catch {
            throw AppError.cacheError(error.localizedDescription)
        }
    }

    public func recentlyPlayedSongs(limit: Int) async throws -> [Song] {
        do {
            var descriptor = FetchDescriptor<CachedSong>(
                predicate: #Predicate { $0.lastPlayedAt != nil },
                sortBy: [SortDescriptor(\.lastPlayedAt, order: .reverse)]
            )
            descriptor.fetchLimit = limit
            let results = try modelContext.fetch(descriptor)
            return results.map { $0.toDomain() }
        } catch {
            throw AppError.cacheError(error.localizedDescription)
        }
    }

    public func clearCache() async throws {
        do {
            try modelContext.delete(model: CachedSong.self)
            try modelContext.save()
        } catch {
            throw AppError.cacheError(error.localizedDescription)
        }
    }
}
