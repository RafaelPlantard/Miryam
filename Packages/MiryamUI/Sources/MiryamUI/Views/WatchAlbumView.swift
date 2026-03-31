import MiryamCore
import MiryamFeatures
import SwiftUI

public struct WatchAlbumView: View {
    @Bindable private var viewModel: AlbumViewModel
    private let onPlaySong: @MainActor (Song) -> Void

    public init(viewModel: AlbumViewModel, onPlaySong: @escaping @MainActor (Song) -> Void) {
        self.viewModel = viewModel
        self.onPlaySong = onPlaySong
    }

    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                VStack(spacing: 8) {
                    Text(error.userMessage)
                        .font(.miryam.bodySmall)
                        .foregroundStyle(Color._miryamLabelSecondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await viewModel.loadSongs() }
                    }
                    .tint(Color._miryamAccent)
                }
            } else {
                List(viewModel.songs) { song in
                    Button {
                        onPlaySong(song)
                    } label: {
                        HStack(spacing: 10) {
                            AsyncImage(url: song.artworkURL(size: 80)) { phase in
                                switch phase {
                                case let .success(image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure, .empty:
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color._miryamSurfaceSecondary)
                                        .overlay(
                                            Image(symbol: .musicNote)
                                                .font(.caption2)
                                                .foregroundStyle(Color._miryamLabelSecondary)
                                        )
                                @unknown default:
                                    Color._miryamSurfaceSecondary
                                }
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 6))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.name)
                                    .font(.miryam.bodySmall)
                                    .foregroundStyle(Color._miryamLabel)
                                    .lineLimit(1)

                                Text(song.artistName)
                                    .font(.miryam.caption)
                                    .foregroundStyle(Color._miryamLabelSecondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .listRowBackground(Color._miryamSurfaceSecondary)
                }
            }
        }
        .accessibilityIdentifier(AccessibilityID.albumView.rawValue)
        .navigationTitle(viewModel.album.name)
        .task {
            await viewModel.loadSongs()
        }
    }
}
