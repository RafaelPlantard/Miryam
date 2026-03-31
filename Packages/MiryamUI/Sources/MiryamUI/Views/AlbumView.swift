import MiryamCore
import MiryamFeatures
import SwiftUI

public struct AlbumView: View {
    @Bindable private var viewModel: AlbumViewModel
    @Environment(Router.self) private var router
    @Environment(PlayerViewModel.self) private var playerViewModel
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
        .accessibilityIdentifier(AccessibilityID.albumView.rawValue)
        .background(Color._miryamBackground)
        .navigationTitle(viewModel.album.name)
        .inlineNavigationTitle()
        .task {
            await viewModel.loadSongs()
        }
    }

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var albumArtworkSize: CGFloat {
        isCompact ? Layout.Album.artworkSizeCompact : Layout.Album.artworkSizeRegular
    }

    private var trackArtworkSize: CGFloat {
        isCompact ? Layout.Album.trackRowArtworkSize : Layout.Album.trackRowArtworkSizeiPad
    }

    private var trackCornerRadius: CGFloat {
        isCompact ? Layout.Album.trackRowCornerRadius : Layout.Album.trackRowCornerRadiusiPad
    }

    private var albumHeader: some View {
        VStack(spacing: 12) {
            AsyncImage(url: viewModel.album.artworkURL(size: 400)) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    RoundedRectangle(cornerRadius: Layout.Album.cornerRadius)
                        .fill(Color._miryamSurface)
                        .overlay(
                            Image(symbol: .musicNoteList)
                                .font(.miryam.iconSmall)
                                .foregroundStyle(Color._miryamLabelSecondary)
                        )
                @unknown default:
                    Color._miryamSurface
                }
            }
            .frame(width: albumArtworkSize, height: albumArtworkSize)
            .clipShape(RoundedRectangle(cornerRadius: Layout.Album.cornerRadius))
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)

            Text(viewModel.album.name)
                .font(isCompact ? .miryam.display20 : .miryam.display32)
                .foregroundStyle(Color._miryamLabel)
                .multilineTextAlignment(.center)

            Text(viewModel.album.artistName)
                .font(isCompact ? .miryam.bodyLarge : .miryam.display20)
                .foregroundStyle(Color._miryamLabelSecondary)

            if viewModel.album.trackCount > 0 || !viewModel.album.genre.isEmpty {
                HStack(spacing: 8) {
                    if viewModel.album.trackCount > 0 {
                        Text("\(viewModel.album.trackCount) tracks")
                    }
                    if viewModel.album.trackCount > 0, !viewModel.album.genre.isEmpty {
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
                        .padding(.leading, trackArtworkSize + (isCompact ? 32 : 36))
                }
            }
        }
    }

    private func trackRow(_ song: Song) -> some View {
        HStack(spacing: isCompact ? 12 : 16) {
            AsyncImage(url: song.artworkURL(size: isCompact ? 88 : 156)) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    RoundedRectangle(cornerRadius: trackCornerRadius)
                        .fill(Color._miryamSurfaceSecondary)
                        .overlay(
                            Image(symbol: .musicNote)
                                .foregroundStyle(Color._miryamSubtitle)
                        )
                @unknown default:
                    Color._miryamSurfaceSecondary
                }
            }
            .frame(width: trackArtworkSize, height: trackArtworkSize)
            .clipShape(RoundedRectangle(cornerRadius: trackCornerRadius))

            VStack(alignment: .leading, spacing: 2) {
                Text(song.name)
                    .font(isCompact ? .miryam.bodyLarge : .miryam.display20)
                    .foregroundStyle(Color._miryamLabel)
                    .lineLimit(1)

                Text(song.artistName)
                    .font(isCompact ? .miryam.bodySmall : .miryam.bodyLarge)
                    .foregroundStyle(Color._miryamLabelSecondary)
                    .lineLimit(1)
            }

            Spacer()

            if song.id == playerViewModel.currentSong?.id, playerViewModel.isPlaying {
                NowPlayingIndicator()
            } else {
                Text(song.formattedDuration)
                    .font(.miryam.bodySmall)
                    .foregroundStyle(Color._miryamLabelSecondary)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onPlaySong(song)
            router.pop()
            router.navigate(to: .player(song))
        }
    }
}
