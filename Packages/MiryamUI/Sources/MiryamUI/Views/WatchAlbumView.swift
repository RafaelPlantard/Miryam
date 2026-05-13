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
        VStack(alignment: .leading, spacing: 4) {
            // Render album name as compact body content rather than via
            // .navigationTitle(): on watchOS, long titles in the nav bar
            // marquee horizontally and overlap the system back chevron at
            // some marquee phases (Apple Music shows the same behavior).
            // Putting the title in body keeps the chevron alone in the
            // nav bar and the title statically truncated, which reads
            // cleanly in App Store screenshots.
            Text(viewModel.album.name)
                .font(.headline)
                .foregroundStyle(Color._miryamLabel)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 8)
                .accessibilityAddTraits(.isHeader)

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
        }
        .accessibilityIdentifier(AccessibilityID.albumView.rawValue)
        .task {
            await viewModel.loadSongs()
        }
    }
}
