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
        isCompact ? Layout.Player.artworkSizeCompact : Layout.Player.artworkSizeRegular
    }

    public var body: some View {
        Group {
            if isCompact {
                compactPlayerLayout
            } else {
                regularPlayerLayout
            }
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
        .navigationTitle(viewModel.currentSong?.albumName ?? "")
        .inlineNavigationTitle()
        .playerToolbar(song: viewModel.currentSong, router: router)
    }

    // MARK: - Compact Layout (iPhone)

    private var compactPlayerLayout: some View {
        ScrollView {
            VStack(spacing: 24) {
                artworkView
                songInfoView
                timelineView
                controlsView
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Regular Layout (iPad)

    private var regularPlayerLayout: some View {
        HStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    artworkView
                    songInfoView
                    timelineView
                    controlsView
                }
                .padding(.horizontal, 48)
                .padding(.top, 48)
                .padding(.bottom, 24)
                .frame(maxWidth: Layout.Player.maxContentWidth)
                .frame(maxWidth: .infinity)
            }

            if !viewModel.queue.isEmpty {
                Divider()

                QueuePanel(
                    songs: viewModel.queue,
                    currentSong: viewModel.currentSong,
                    isPlaying: viewModel.isPlaying,
                    onSelect: { song in
                        Task { await viewModel.play(song) }
                    }
                )
            }
        }
    }

    // MARK: - Artwork

    private var artworkView: some View {
        Group {
            if let song = viewModel.currentSong {
                CachedAsyncImage(url: song.artworkURL(size: 600)) { phase in
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
        .clipShape(RoundedRectangle(cornerRadius: Layout.Player.artworkCornerRadius))
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        .accessibilityHidden(true)
    }

    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: Layout.Player.artworkCornerRadius)
            .fill(Color._miryamSurface)
            .overlay(
                Image(symbol: .musicNote)
                    .font(.miryam.iconLarge)
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

            HStack(spacing: 8) {
                Text(viewModel.currentSong?.artistName ?? "")
                    .font(.miryam.bodyLarge)
                    .foregroundStyle(Color._miryamLabelSecondary)
                    .lineLimit(1)

                if viewModel.currentSong != nil {
                    repeatButton
                }
            }
            .frame(minHeight: Layout.Player.minTapTarget)

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
                        .frame(minHeight: Layout.Player.minTapTarget)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("View album \(song.albumName)")
            }
        }
    }

    private var repeatButton: some View {
        Button {
            Task { await viewModel.toggleRepeat() }
        } label: {
            Image(symbol: viewModel.repeatMode == .one ? .repeatOne : .repeatIcon)
                .font(.miryam.bodySmall)
                .foregroundStyle(
                    viewModel.repeatMode == .off
                        ? Color._miryamLabelTertiary
                        : Color._miryamAccent
                )
                .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
                .contentShape(Rectangle())
        }
        .accessibilityIdentifier(AccessibilityID.repeatButton.rawValue)
        .accessibilityLabel("Repeat")
        .accessibilityValue(repeatAccessibilityValue)
    }

    private var repeatAccessibilityValue: String {
        switch viewModel.repeatMode {
        case .off: "Off"
        case .all: "All"
        case .one: "One"
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
                        .frame(height: Layout.Player.trackHeight)

                    // Progress fill
                    Capsule()
                        .fill(Color._miryamAccent)
                        .frame(
                            width: max(0, geometry.size.width * viewModel.playbackState.progress),
                            height: Layout.Player.trackHeight
                        )
                        .animation(.linear(duration: 0.05), value: viewModel.playbackState.progress)

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
            .frame(height: Layout.Player.minTapTarget)
            .contentShape(Rectangle())
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
        HStack(spacing: Layout.Player.controlSpacing) {
            Button {
                Task { await viewModel.skipToPrevious() }
            } label: {
                Image(symbol: .backwardEnd)
                    .font(.miryam.controlRegular)
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
                    .contentShape(Rectangle())
            }
            .accessibilityIdentifier(AccessibilityID.previousTrack.rawValue)
            .accessibilityLabel("Previous track")

            Button {
                Task { await viewModel.skipBackward() }
            } label: {
                Image(symbol: .skipBackward15)
                    .font(.miryam.controlRegular)
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
                    .contentShape(Rectangle())
            }
            .accessibilityIdentifier(AccessibilityID.skipBackward.rawValue)
            .accessibilityLabel("Skip backward 15 seconds")

            Button {
                Task { await viewModel.togglePlayPause() }
            } label: {
                Image(symbol: viewModel.isPlaying ? .pauseFill : .playFill)
                    .font(.miryam.controlLarge)
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: Layout.Player.playButtonSize, height: Layout.Player.playButtonSize)
                    .background(Color._miryamSurfaceSecondary, in: Circle())
            }
            .accessibilityIdentifier(AccessibilityID.playPause.rawValue)
            .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")
            .accessibilityValue(viewModel.isPlaying ? "Playing" : "Paused")

            Button {
                Task { await viewModel.skipForward() }
            } label: {
                Image(symbol: .skipForward15)
                    .font(.miryam.controlRegular)
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
                    .contentShape(Rectangle())
            }
            .accessibilityIdentifier(AccessibilityID.skipForward.rawValue)
            .accessibilityLabel("Skip forward 15 seconds")

            Button {
                Task { await viewModel.skipToNext() }
            } label: {
                Image(symbol: .forwardEnd)
                    .font(.miryam.controlRegular)
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
                    .contentShape(Rectangle())
            }
            .accessibilityIdentifier(AccessibilityID.nextTrack.rawValue)
            .accessibilityLabel("Next track")
        }
    }
}
