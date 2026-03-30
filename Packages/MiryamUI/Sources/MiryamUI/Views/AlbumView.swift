import SwiftUI
import MiryamCore
import MiryamFeatures

public struct AlbumView: View {
    @Bindable private var viewModel: AlbumViewModel
    @Environment(Router.self) private var router
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let onPlaySong: @MainActor (Song) -> Void

    public init(viewModel: AlbumViewModel, onPlaySong: @escaping @MainActor (Song) -> Void) {
        self.viewModel = viewModel
        self.onPlaySong = onPlaySong
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Album header
                albumHeader

                Divider()
                    .background(Color._miryamSurfaceSecondary)

                // Track listing
                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.large)
                        .padding(.top, 32)
                } else if let error = viewModel.error {
                    VStack(spacing: 12) {
                        Text(error.userMessage)
                            .font(.miryam.bodyLarge)
                            .foregroundStyle(Color._miryamLabelSecondary)
                        Button("Try Again") {
                            Task { await viewModel.loadSongs() }
                        }
                        .tint(Color._miryamAccent)
                    }
                    .padding(.top, 32)
                } else {
                    trackList
                }
            }
        }
        .background(Color._miryamBackground)
        .navigationTitle(viewModel.album.name)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await viewModel.loadSongs()
        }
    }

    private var albumArtworkSize: CGFloat {
        horizontalSizeClass == .compact ? 200 : 280
    }

    private var albumHeader: some View {
        VStack(spacing: 12) {
            AsyncImage(url: viewModel.album.artworkURL(size: 400)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color._miryamSurface)
                        .overlay(
                            Image(systemName: "music.note.list")
                                .font(.system(size: 40))
                                .foregroundStyle(Color._miryamLabelSecondary)
                        )
                @unknown default:
                    Color._miryamSurface
                }
            }
            .frame(width: albumArtworkSize, height: albumArtworkSize)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)

            Text(viewModel.album.name)
                .font(.miryam.display)
                .foregroundStyle(Color._miryamLabel)
                .multilineTextAlignment(.center)

            Text(viewModel.album.artistName)
                .font(.miryam.bodyLarge)
                .foregroundStyle(Color._miryamLabelSecondary)

            if viewModel.album.trackCount > 0 || !viewModel.album.genre.isEmpty {
                HStack(spacing: 8) {
                    if viewModel.album.trackCount > 0 {
                        Text("\(viewModel.album.trackCount) tracks")
                    }
                    if viewModel.album.trackCount > 0 && !viewModel.album.genre.isEmpty {
                        Text("·")
                    }
                    if !viewModel.album.genre.isEmpty {
                        Text(viewModel.album.genre)
                    }
                }
                .font(.miryam.bodySmall)
                .foregroundStyle(Color._miryamLabelTertiary)
            }
        }
        .padding(.top, 16)
    }

    private var trackList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.songs) { song in
                trackRow(song)

                if song.id != viewModel.songs.last?.id {
                    Divider()
                        .padding(.leading, 52)
                }
            }
        }
    }

    private func trackRow(_ song: Song) -> some View {
        HStack(spacing: 12) {
            Text("\(song.trackNumber)")
                .font(.miryam.bodySmall)
                .foregroundStyle(Color._miryamLabelSecondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(song.name)
                    .font(.miryam.bodyLarge)
                    .foregroundStyle(Color._miryamLabel)
                    .lineLimit(1)

                Text(song.artistName)
                    .font(.miryam.bodySmall)
                    .foregroundStyle(Color._miryamLabelSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(song.formattedDuration)
                .font(.miryam.bodySmall)
                .foregroundStyle(Color._miryamLabelSecondary)
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            onPlaySong(song)
            router.navigate(to: .player(song))
        }
    }
}
