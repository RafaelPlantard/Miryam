import SwiftUI
import MiryamCore
import MiryamFeatures

public struct PlayerView: View {
    @Bindable private var viewModel: PlayerViewModel
    @Environment(Router.self) private var router
    @GestureState private var isDragging = false

    public init(viewModel: PlayerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 24) {
            // Artwork
            artworkView

            // Song info
            songInfoView

            // Timeline (MANDATORY)
            timelineView

            // Controls
            controlsView

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color._miryamBackground)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: - Artwork

    private var artworkView: some View {
        Group {
            if let song = viewModel.currentSong {
                AsyncImage(url: song.artworkURL(size: 600)) { phase in
                    switch phase {
                    case .success(let image):
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
        .frame(width: 300, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        .accessibilityHidden(true)
    }

    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 16)
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
                .font(.miryam.display)
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
                        .fill(Color._miryamSurfaceSecondary)
                        .frame(height: 4)

                    // Progress fill
                    Capsule()
                        .fill(Color._miryamAccent)
                        .frame(
                            width: max(0, geometry.size.width * viewModel.playbackState.progress),
                            height: 4
                        )

                    // Drag handle
                    Circle()
                        .fill(Color._miryamAccent)
                        .frame(width: isDragging ? 16 : 8, height: isDragging ? 16 : 8)
                        .offset(x: max(0, geometry.size.width * viewModel.playbackState.progress - 4))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .updating($isDragging) { _, state, _ in
                                    state = true
                                }
                                .onChanged { value in
                                    let progress = max(0, min(1, value.location.x / geometry.size.width))
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
            .accessibilityLabel("Song progress")
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
                    .font(.title)
                    .foregroundStyle(Color._miryamIconPrimary)
            }
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityLabel("Skip backward 15 seconds")

            Button {
                Task { await viewModel.togglePlayPause() }
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color._miryamAccent)
            }
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")
            .accessibilityValue(viewModel.isPlaying ? "Playing" : "Paused")

            Button {
                Task { await viewModel.skipForward() }
            } label: {
                Image(systemName: "goforward.15")
                    .font(.title)
                    .foregroundStyle(Color._miryamIconPrimary)
            }
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityLabel("Skip forward 15 seconds")
        }
    }
}
