import MiryamCore
import MiryamFeatures
import SwiftUI

public struct PlayerView: View {
    @Bindable private var viewModel: PlayerViewModel
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
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

    private var compactTimelineTrackColor: Color {
        .white.opacity(0.2)
    }

    private var compactTimelineProgressColor: Color {
        .white.opacity(0.9)
    }

    private var compactPrimaryControlColor: Color {
        .white
    }

    private var compactSecondaryControlColor: Color {
        .white.opacity(0.78)
    }

    private var compactPeripheralControlColor: Color {
        .white.opacity(0.45)
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
        .navigationTitle(isCompact ? "" : (viewModel.currentSong?.albumName ?? ""))
        .inlineNavigationTitle()
        .modifier(PlayerToolbarModifier(isCompact: isCompact, song: viewModel.currentSong, router: router))
    }

    // MARK: - Compact Layout (iPhone)

    private var compactPlayerLayout: some View {
        ZStack {
            compactBackground

            VStack(spacing: 0) {
                compactHeader
                    .padding(.horizontal, 8)
                    .padding(.top, Layout.Player.compactTopPadding)

                Spacer(minLength: Layout.Player.compactArtworkTopSpacing)

                VStack(spacing: 24) {
                    artworkView
                    songInfoView
                }
                .padding(.horizontal, Layout.Player.compactHorizontalPadding)

                Spacer(minLength: 32)

                VStack(spacing: Layout.Player.compactBottomSectionSpacing) {
                    timelineView
                    controlsView
                }
                .padding(.horizontal, Layout.Player.compactHorizontalPadding)
                .padding(.bottom, Layout.Player.compactBottomPadding)
            }
        }
        .ignoresSafeArea()
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

    private var compactBackground: some View {
        ZStack {
            if let song = viewModel.currentSong {
                CachedAsyncImage(url: song.artworkURL(size: 600)) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        LinearGradient.spotlight
                    @unknown default:
                        LinearGradient.spotlight
                    }
                }
                .scaleEffect(1.4)
                .blur(radius: 60)
            } else {
                LinearGradient.spotlight
            }

            Color.black.opacity(0.72)
        }
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

    private var compactHeader: some View {
        HStack(spacing: 8) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(compactPrimaryControlColor)
                    .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close player")

            Text(compactHeaderTitle)
                .font(.miryam.display)
                .foregroundStyle(compactPrimaryControlColor)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Button {
                if let song = viewModel.currentSong {
                    router.presentSheet(.moreOptions(song))
                }
            } label: {
                Image(symbol: .ellipsis)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(compactPrimaryControlColor)
                    .frame(width: 28, height: 28)
                    .background(.white.opacity(0.1), in: Circle())
                    .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.moreOptionsButton.rawValue)
            .accessibilityLabel("More options")
            .opacity(viewModel.currentSong == nil ? 0 : 1)
        }
        .frame(height: Layout.Player.compactHeaderHeight)
    }

    private var compactHeaderTitle: String {
        guard let song = viewModel.currentSong else { return "Not Playing" }
        return "\(song.name) — \(song.artistName)"
    }

    // MARK: - Song Info

    private var songInfoView: some View {
        VStack(spacing: 4) {
            Text(viewModel.currentSong?.name ?? "Not Playing")
                .font(.miryam.display32)
                .foregroundStyle(isCompact ? compactPrimaryControlColor : Color._miryamLabel)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Text(viewModel.currentSong?.artistName ?? "")
                    .font(.miryam.bodyLarge)
                    .foregroundStyle(isCompact ? compactSecondaryControlColor : Color._miryamLabelSecondary)
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
                        .foregroundStyle(isCompact ? compactPrimaryControlColor.opacity(0.82) : Color._miryamAccent)
                        .lineLimit(1)
                        .frame(
                            minWidth: Layout.Player.minTapTarget,
                            minHeight: Layout.Player.minTapTarget
                        )
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("View album \(song.albumName)")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var repeatButton: some View {
        Button {
            Task { await viewModel.toggleRepeat() }
        } label: {
            Image(symbol: viewModel.repeatMode == .one ? .repeatOne : .repeatIcon)
                .font(.miryam.bodySmall)
                .foregroundStyle(
                    isCompact
                        ? (viewModel.repeatMode == .off ? compactPeripheralControlColor : compactPrimaryControlColor)
                        : (viewModel.repeatMode == .off ? Color._miryamLabelTertiary : Color._miryamAccent)
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
                        .fill(isCompact ? compactTimelineTrackColor : Color._miryamLabelTertiary)
                        .frame(height: Layout.Player.trackHeight)

                    // Progress fill
                    Capsule()
                        .fill(isCompact ? compactTimelineProgressColor : Color._miryamAccent)
                        .frame(
                            width: max(0, geometry.size.width * viewModel.playbackState.progress),
                            height: Layout.Player.trackHeight
                        )
                        .animation(.linear(duration: 0.05), value: viewModel.playbackState.progress)

                    // Drag handle
                    TimelineHandle(
                        progress: viewModel.playbackState.progress,
                        trackWidth: geometry.size.width,
                        color: isCompact ? compactTimelineProgressColor : Color._miryamAccent,
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
                    .foregroundStyle(isCompact ? compactSecondaryControlColor : Color._miryamLabelSecondary)
                    .monospacedDigit()

                Spacer()

                Text(viewModel.playbackState.formattedRemainingTime)
                    .font(.miryam.bodySmall)
                    .foregroundStyle(isCompact ? compactSecondaryControlColor : Color._miryamLabelSecondary)
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
                    .foregroundStyle(isCompact ? compactPeripheralControlColor : Color._miryamIconPrimary)
                    .frame(width: Layout.Player.secondaryControlSize, height: Layout.Player.secondaryControlSize)
                    .contentShape(Rectangle())
            }
            .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
            .accessibilityIdentifier(AccessibilityID.previousTrack.rawValue)
            .accessibilityLabel("Previous track")

            Button {
                Task { await viewModel.skipBackward() }
            } label: {
                Image(symbol: .skipBackward15)
                    .font(.miryam.controlRegular)
                    .foregroundStyle(isCompact ? compactSecondaryControlColor : Color._miryamIconPrimary)
                    .frame(width: Layout.Player.secondaryControlSize, height: Layout.Player.secondaryControlSize)
                    .contentShape(Rectangle())
            }
            .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
            .accessibilityIdentifier(AccessibilityID.skipBackward.rawValue)
            .accessibilityLabel("Skip backward 15 seconds")

            Button {
                Task { await viewModel.togglePlayPause() }
            } label: {
                Image(symbol: viewModel.isPlaying ? .pauseFill : .playFill)
                    .font(.miryam.controlLarge)
                    .foregroundStyle(isCompact ? compactPrimaryControlColor : Color._miryamIconPrimary)
                    .frame(width: Layout.Player.playButtonSize, height: Layout.Player.playButtonSize)
                    .background(
                        isCompact ? compactPrimaryControlColor.opacity(0.15) : Color._miryamSurfaceSecondary,
                        in: Circle()
                    )
            }
            .accessibilityIdentifier(AccessibilityID.playPause.rawValue)
            .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")
            .accessibilityValue(viewModel.isPlaying ? "Playing" : "Paused")

            Button {
                Task { await viewModel.skipForward() }
            } label: {
                Image(symbol: .skipForward15)
                    .font(.miryam.controlRegular)
                    .foregroundStyle(isCompact ? compactSecondaryControlColor : Color._miryamIconPrimary)
                    .frame(width: Layout.Player.secondaryControlSize, height: Layout.Player.secondaryControlSize)
                    .contentShape(Rectangle())
            }
            .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
            .accessibilityIdentifier(AccessibilityID.skipForward.rawValue)
            .accessibilityLabel("Skip forward 15 seconds")

            Button {
                Task { await viewModel.skipToNext() }
            } label: {
                Image(symbol: .forwardEnd)
                    .font(.miryam.controlRegular)
                    .foregroundStyle(isCompact ? compactPeripheralControlColor : Color._miryamIconPrimary)
                    .frame(width: Layout.Player.secondaryControlSize, height: Layout.Player.secondaryControlSize)
                    .contentShape(Rectangle())
            }
            .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
            .accessibilityIdentifier(AccessibilityID.nextTrack.rawValue)
            .accessibilityLabel("Next track")
        }
    }
}

private struct PlayerToolbarModifier: ViewModifier {
    let isCompact: Bool
    let song: Song?
    let router: Router

    @ViewBuilder
    func body(content: Content) -> some View {
        if isCompact {
            content
        } else {
            content.playerToolbar(song: song, router: router)
        }
    }
}
