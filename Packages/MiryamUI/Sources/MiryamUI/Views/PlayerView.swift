import MiryamCore
import MiryamFeatures
import SwiftUI

public struct PlayerView: View {
    @Bindable private var viewModel: PlayerViewModel
    @Environment(Router.self) private var router
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    public init(viewModel: PlayerViewModel) {
        self.viewModel = viewModel
    }

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    private var artworkSize: CGFloat {
        if isCompact { return Layout.Player.artworkSizeCompact }
        if isLandscape { return Layout.Player.artworkSizeiPadLandscape }
        return Layout.Player.artworkSizeRegular
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
                    Rectangle()
                        .fill(.ultraThinMaterial)
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color._miryamAccent)
                }
                .ignoresSafeArea()
                .accessibilityLabel(Text(L10n.loadingSong))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.playerView.rawValue)
        .background(Color._miryamBackground)
        .navigationTitle(isCompact ? "" : (viewModel.currentSong?.albumName ?? ""))
        .inlineNavigationTitle()
        .modifier(PlayerToolbarModifier(isCompact: isCompact, song: viewModel.currentSong, router: router))
    }

    // MARK: - Compact Layout (iPhone)

    private var compactPlayerLayout: some View {
        VStack(spacing: 0) {
            compactHeader
                .padding(.horizontal, 8)

            Spacer(minLength: Layout.Player.compactArtworkTopSpacing)

            artworkView

            Spacer(minLength: 32)

            VStack(spacing: Layout.Player.compactBottomSectionSpacing) {
                songInfoView
                timelineView
                controlsView
            }
            .padding(.horizontal, Layout.Player.compactHorizontalPadding)
            .padding(.bottom, Layout.Player.compactBottomPadding)
        }
        .background {
            compactBackground
                .ignoresSafeArea()
        }
    }

    // MARK: - Regular Layout (iPad)

    private var regularPlayerLayout: some View {
        HStack(spacing: 0) {
            ScrollView {
                VStack(spacing: isLandscape ? 16 : 32) {
                    artworkView
                    songInfoView
                    timelineView
                    controlsView
                }
                .padding(.horizontal, isLandscape ? 32 : 48)
                .padding(.top, isLandscape ? 16 : 48)
                .padding(.bottom, isLandscape ? 12 : 24)
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

            Color._miryamBackground.opacity(0.72)
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
                router.pop()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color._miryamLabel)
                    .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(L10n.closePlayer))

            Text(compactHeaderTitle)
                .font(.miryam.display)
                .foregroundStyle(Color._miryamLabel)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Button {
                if let song = viewModel.currentSong {
                    router.presentSheet(.moreOptions(song))
                }
            } label: {
                Image(symbol: .ellipsis)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color._miryamLabel)
                    .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.moreOptionsButton.rawValue)
            .accessibilityLabel(Text(L10n.moreOptions))
            .opacity(viewModel.currentSong == nil ? 0 : 1)
        }
        .frame(height: Layout.Player.compactHeaderHeight)
    }

    private var compactHeaderTitle: String {
        viewModel.currentSong?.albumName ?? L10n.string(L10n.notPlaying)
    }

    // MARK: - Song Info

    private var songInfoView: some View {
        VStack(spacing: 4) {
            Text(viewModel.currentSong?.name ?? L10n.string(L10n.notPlaying))
                .font(.miryam.display32)
                .foregroundStyle(Color._miryamLabel)
                .lineLimit(2)
                .multilineTextAlignment(isCompact ? .leading : .center)

            HStack(spacing: 8) {
                Text(viewModel.currentSong?.artistName ?? "")
                    .font(.miryam.bodyLarge)
                    .foregroundStyle(Color._miryamLabelSecondary)
                    .lineLimit(1)

                if isCompact {
                    Spacer(minLength: 0)
                }

                if viewModel.currentSong != nil {
                    repeatButton
                }
            }
            .frame(minHeight: Layout.Player.minTapTarget)

            if !isCompact, let song = viewModel.currentSong {
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
                        .frame(
                            minWidth: Layout.Player.minTapTarget,
                            minHeight: Layout.Player.minTapTarget
                        )
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(L10n.viewAlbum(for: song.albumName))
            }
        }
        .frame(maxWidth: .infinity, alignment: isCompact ? .leading : .center)
    }

    private var repeatButton: some View {
        Button {
            Task { await viewModel.toggleRepeat() }
        } label: {
            Image(symbol: viewModel.repeatMode == .one ? .repeatOne : .repeatIcon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(
                    viewModel.repeatMode == .off ? Color._miryamLabelTertiary : Color._miryamAccent
                )
                .frame(width: 24, height: 24)
                .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
                .contentShape(Rectangle())
        }
        .accessibilityIdentifier(AccessibilityID.repeatButton.rawValue)
        .accessibilityLabel(Text(L10n.repeatLabel))
        .accessibilityValue(repeatAccessibilityValue)
    }

    private var repeatAccessibilityValue: String {
        switch viewModel.repeatMode {
        case .off: L10n.string(L10n.off)
        case .all: L10n.string(L10n.all)
        case .one: L10n.string(L10n.one)
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
                        color: Color._miryamAccent,
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
            .accessibilityIdentifier(AccessibilityID.songProgress.rawValue)
            .accessibilityLabel(Text(L10n.playbackProgress))
            .accessibilityHint(Text(L10n.dragToSeekWithinTheSong))
            .accessibilityValue(L10n.percentage(viewModel.playbackState.progress))

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
                    .frame(width: Layout.Player.secondaryControlSize, height: Layout.Player.secondaryControlSize)
                    .contentShape(Rectangle())
            }
            .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
            .accessibilityIdentifier(AccessibilityID.previousTrack.rawValue)
            .accessibilityLabel(Text(L10n.previousTrack))

            Button {
                Task { await viewModel.skipBackward() }
            } label: {
                Image(symbol: .skipBackward5)
                    .font(.miryam.controlRegular)
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: Layout.Player.secondaryControlSize, height: Layout.Player.secondaryControlSize)
                    .contentShape(Rectangle())
            }
            .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
            .accessibilityIdentifier(AccessibilityID.skipBackward.rawValue)
            .accessibilityLabel(Text(L10n.skipBackward5))

            Button {
                Task { await viewModel.togglePlayPause() }
            } label: {
                Image(symbol: viewModel.isPlaying ? .pauseFill : .playFill)
                    .font(.miryam.controlLarge)
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: Layout.Player.playButtonSize, height: Layout.Player.playButtonSize)
                    .background(
                        Color._miryamSurfaceSecondary,
                        in: Circle()
                    )
            }
            .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
            .accessibilityIdentifier(AccessibilityID.playPause.rawValue)
            .accessibilityLabel(Text(viewModel.isPlaying ? L10n.pause : L10n.play))
            .accessibilityValue(viewModel.isPlaying ? L10n.string(L10n.playing) : L10n.string(L10n.paused))

            Button {
                Task { await viewModel.skipForward() }
            } label: {
                Image(symbol: .skipForward5)
                    .font(.miryam.controlRegular)
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: Layout.Player.secondaryControlSize, height: Layout.Player.secondaryControlSize)
                    .contentShape(Rectangle())
            }
            .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
            .accessibilityIdentifier(AccessibilityID.skipForward.rawValue)
            .accessibilityLabel(Text(L10n.skipForward5))

            Button {
                Task { await viewModel.skipToNext() }
            } label: {
                Image(symbol: .forwardEnd)
                    .font(.miryam.controlRegular)
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: Layout.Player.secondaryControlSize, height: Layout.Player.secondaryControlSize)
                    .contentShape(Rectangle())
            }
            .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
            .accessibilityIdentifier(AccessibilityID.nextTrack.rawValue)
            .accessibilityLabel(Text(L10n.nextTrack))
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
            content.hideNavigationBarChrome()
        } else {
            content.playerToolbar(song: song, router: router, isCompact: false)
        }
    }
}
