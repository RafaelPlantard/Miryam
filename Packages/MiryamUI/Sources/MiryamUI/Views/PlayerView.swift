import MiryamCore
import MiryamFeatures
import SwiftUI

public struct PlayerView: View {
    @Bindable private var viewModel: PlayerViewModel
    @Environment(Router.self) private var router
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public init(viewModel: PlayerViewModel) {
        self.viewModel = viewModel
    }

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var artworkSize: CGFloat {
        isCompact ? 264 : 360
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: isCompact ? 24 : 32) {
                // Artwork
                artworkView

                // Song info
                songInfoView

                // Timeline (MANDATORY)
                timelineView

                // Controls
                controlsView
            }
            .padding(.horizontal, isCompact ? 24 : 48)
            .padding(.top, isCompact ? 32 : 48)
            .padding(.bottom, 24)
            .frame(maxWidth: isCompact ? .infinity : 600)
            .frame(maxWidth: .infinity)
        }
        .overlay {
            if viewModel.isBuffering {
                ZStack {
                    Color._miryamBackground.opacity(0.6)
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color._miryamAccent)
                }
                .ignoresSafeArea()
                .accessibilityLabel(AccessibilityID.loadingSong.rawValue)
            }
        }
        .accessibilityIdentifier(AccessibilityID.playerView.rawValue)
        .background(Color._miryamBackground)
        .inlineNavigationTitle()
        .playerToolbar(song: viewModel.currentSong, router: router)
    }

    // MARK: - Artwork

    private var artworkView: some View {
        Group {
            if let song = viewModel.currentSong {
                AsyncImage(url: song.artworkURL(size: 600)) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        artworkPlaceholder
                    @unknown default:
                        artworkPlaceholder
                    }
                }
            } else {
                artworkPlaceholder
            }
        }
        .frame(width: artworkSize, height: artworkSize)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        .accessibilityHidden(true)
    }

    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(Color._miryamSurface)
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: 60))
                    .foregroundStyle(Color._miryamLabelSecondary)
            )
    }

    // MARK: - Song Info

    private var songInfoView: some View {
        VStack(spacing: 4) {
            Text(viewModel.currentSong?.name ?? "Not Playing")
                .font(.miryam.display32)
                .foregroundStyle(Color._miryamLabel)
                .lineLimit(1)

            Text(viewModel.currentSong?.artistName ?? "")
                .font(.miryam.bodyLarge)
                .foregroundStyle(Color._miryamLabelSecondary)
                .lineLimit(1)

            if let song = viewModel.currentSong {
                Button {
                    let album = Album(
                        id: song.albumId,
                        name: song.albumName,
                        artistName: song.artistName,
                        artworkURL: song.artworkURL,
                        trackCount: 0,
                        releaseDate: nil,
                        genre: ""
                    )
                    router.navigate(to: .album(album))
                } label: {
                    Text(song.albumName)
                        .font(.miryam.bodySmall)
                        .foregroundStyle(Color._miryamAccent)
                        .lineLimit(1)
                }
                .accessibilityLabel("View album \(song.albumName)")
            }
        }
    }

    // MARK: - Timeline (MANDATORY)

    private var timelineView: some View {
        VStack(spacing: 8) {
            // Progress slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .fill(Color._miryamLabelTertiary)
                        .frame(height: 4)

                    // Progress fill
                    Capsule()
                        .fill(Color._miryamAccent)
                        .frame(
                            width: max(0, geometry.size.width * viewModel.playbackState.progress),
                            height: 4
                        )

                    // Drag handle
                    TimelineHandle(
                        progress: viewModel.playbackState.progress,
                        trackWidth: geometry.size.width,
                        onSeek: { progress in
                            let viewModel = viewModel
                            Task { @MainActor in
                                await viewModel.seek(to: progress)
                            }
                        }
                    )
                }
            }
            .frame(height: 16)
            .accessibilityElement()
            .accessibilityLabel(AccessibilityID.songProgress.rawValue)
            .accessibilityValue("\(Int(viewModel.playbackState.progress * 100))%")

            // Time labels
            HStack {
                Text(viewModel.playbackState.formattedCurrentTime)
                    .font(.miryam.bodySmall)
                    .foregroundStyle(Color._miryamLabelSecondary)
                    .monospacedDigit()

                Spacer()

                Text(viewModel.playbackState.formattedRemainingTime)
                    .font(.miryam.bodySmall)
                    .foregroundStyle(Color._miryamLabelSecondary)
                    .monospacedDigit()
            }
        }
    }

    // MARK: - Controls

    private var controlsView: some View {
        HStack(spacing: 40) {
            Button {
                Task { await viewModel.skipBackward() }
            } label: {
                Image(systemName: "gobackward.15")
                    .font(.system(size: 20))
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: 36, height: 36)
            }
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityIdentifier(AccessibilityID.skipBackward.rawValue)
            .accessibilityLabel("Skip backward 15 seconds")

            Button {
                Task { await viewModel.togglePlayPause() }
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: 72, height: 72)
                    .background(Color._miryamSurfaceSecondary, in: Circle())
            }
            .accessibilityIdentifier(AccessibilityID.playPause.rawValue)
            .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")
            .accessibilityValue(viewModel.isPlaying ? "Playing" : "Paused")

            Button {
                Task { await viewModel.skipForward() }
            } label: {
                Image(systemName: "goforward.15")
                    .font(.system(size: 20))
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: 36, height: 36)
            }
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityIdentifier(AccessibilityID.skipForward.rawValue)
            .accessibilityLabel("Skip forward 15 seconds")
        }
    }
}
