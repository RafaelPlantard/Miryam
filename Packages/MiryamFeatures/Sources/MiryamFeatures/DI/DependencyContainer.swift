import Foundation
import MiryamCore
import MiryamNetworking
import MiryamPersistence
import MiryamPlayer
import SwiftData

/// Holds all concrete implementations and creates ViewModels.
@MainActor
public final class DependencyContainer {
    public let songRepository: any SongRepositoryProtocol
    public let cacheRepository: any CacheRepositoryProtocol
    public let player: any PlayerProtocol
    public let modelContainer: ModelContainer

    private var albumViewModels: [Int: AlbumViewModel] = [:]

    public init() throws {
        let httpClient = HTTPClient()
        self.songRepository = SongRepository(httpClient: httpClient)
        self.modelContainer = try PersistenceContainer.makeContainer()
        self.cacheRepository = CacheActor(modelContainer: modelContainer)
        self.player = AudioPlayer()
    }

    /// For testing with custom dependencies.
    public init(
        songRepository: any SongRepositoryProtocol,
        cacheRepository: any CacheRepositoryProtocol,
        player: any PlayerProtocol,
        modelContainer: ModelContainer
    ) {
        self.songRepository = songRepository
        self.cacheRepository = cacheRepository
        self.player = player
        self.modelContainer = modelContainer
    }

    public func makeSongsViewModel() -> SongsViewModel {
        SongsViewModel(
            songRepository: songRepository,
            cacheRepository: cacheRepository
        )
    }

    public func makePlayerViewModel() -> PlayerViewModel {
        PlayerViewModel(
            player: player,
            cacheRepository: cacheRepository
        )
    }

    public func makeAlbumViewModel(album: Album) -> AlbumViewModel {
        if let cached = albumViewModels[album.id] {
            return cached
        }
        let viewModel = AlbumViewModel(
            album: album,
            songRepository: songRepository
        )
        albumViewModels[album.id] = viewModel
        return viewModel
    }
}
