import MiryamCore
import MiryamFeatures
import SwiftUI

public struct WatchNowPlayingView: View {
    @Bindable var viewModel: PlayerViewModel

    public init(viewModel: PlayerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 8) {
            if let song = viewModel.currentSong {
                AsyncImage(url: song.artworkURL(size: 200)) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color._miryamSurfaceSecondary)
                            .overlay(
                                Image(symbol: .musicNote)
                                    .foregroundStyle(.secondary)
                            )
                    @unknown default:
                        Color._miryamSurfaceSecondary
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .accessibilityHidden(true)

                Text(song.name)
                    .font(.headline)
                    .foregroundStyle(Color._miryamLabel)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                Text(song.artistName)
                    .font(.caption)
                    .foregroundStyle(Color._miryamLabelSecondary)
                    .lineLimit(1)
            } else {
                Image(symbol: .musicNote)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text(L10n.string(L10n.notPlaying))
                    .font(.headline)
            }

            // Controls
            HStack(spacing: 20) {
                Button {
                    Task { await viewModel.skipToPrevious() }
                } label: {
                    Image(symbol: .backwardEnd)
                        .font(.title3)
                        .foregroundStyle(Color._miryamIconPrimary)
                }
                .accessibilityIdentifier(AccessibilityID.previousTrack.rawValue)
                .accessibilityLabel(Text(L10n.previousTrack))

                Button {
                    Task { await viewModel.togglePlayPause() }
                } label: {
                    ZStack {
                        // Track background
                        Circle()
                            .stroke(Color._miryamLabelTertiary, lineWidth: 3)
                            .frame(width: 48, height: 48)

                        // Progress ring
                        Circle()
                            .trim(from: 0, to: viewModel.playbackState.progress)
                            .stroke(Color._miryamAccent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 48, height: 48)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.05), value: viewModel.playbackState.progress)

                        // Play/pause icon
                        Image(symbol: viewModel.isPlaying ? .pauseFill : .playFill)
                            .font(.title3)
                            .foregroundStyle(Color._miryamIconPrimary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(AccessibilityID.playPause.rawValue)
                .accessibilityLabel(Text(viewModel.isPlaying ? L10n.pause : L10n.play))
                .accessibilityValue(viewModel.isPlaying ? L10n.string(L10n.playing) : L10n.string(L10n.paused))

                Button {
                    Task { await viewModel.skipToNext() }
                } label: {
                    Image(symbol: .forwardEnd)
                        .font(.title3)
                        .foregroundStyle(Color._miryamIconPrimary)
                }
                .accessibilityIdentifier(AccessibilityID.nextTrack.rawValue)
                .accessibilityLabel(Text(L10n.nextTrack))
            }
        }
        .padding()
        .accessibilityIdentifier(AccessibilityID.watchNowPlayingView.rawValue)
    }
}
