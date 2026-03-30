import Foundation
import MiryamCore

/// ViewModel for the Album screen.
@Observable
@MainActor
public final class AlbumViewModel {
    // MARK: - Published State

    public let album: Album
    public var songs: [Song] = []
    public var isLoading = false
    public var error: AppError?

    // MARK: - Private

    private let songRepository: any SongRepositoryProtocol

    public init(
        album: Album,
        songRepository: any SongRepositoryProtocol
    ) {
        self.album = album
        self.songRepository = songRepository
    }

    /// Load all songs in the album.
    public func loadSongs() async {
        guard songs.isEmpty else { return }

        isLoading = true
        error = nil

        do {
            songs = try await songRepository.fetchAlbumSongs(albumId: album.id)
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }

        isLoading = false
    }
}
