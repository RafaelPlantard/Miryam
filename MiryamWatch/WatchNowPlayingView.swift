import SwiftUI
import MiryamCore
import MiryamFeatures

struct WatchNowPlayingView: View {
    @Bindable var viewModel: PlayerViewModel

    var body: some View {
        VStack(spacing: 8) {
            if let song = viewModel.currentSong {
                Text(song.name)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(song.artistName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Timeline
                ProgressView(value: viewModel.playbackState.progress)
                    .tint(.accentColor)

                HStack {
                    Text(viewModel.playbackState.formattedCurrentTime)
                    Spacer()
                    Text(viewModel.playbackState.formattedRemainingTime)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            } else {
                Image(systemName: "music.note")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Not Playing")
                    .font(.headline)
            }

            // Controls
            HStack(spacing: 20) {
                Button {
                    Task { await viewModel.skipBackward() }
                } label: {
                    Image(systemName: "gobackward.15")
                }

                Button {
                    Task { await viewModel.togglePlayPause() }
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }

                Button {
                    Task { await viewModel.skipForward() }
                } label: {
                    Image(systemName: "goforward.15")
                }
            }
        }
        .padding()
    }
}
