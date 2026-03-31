import MiryamCore
import MiryamFeatures
import SwiftUI

/// A sidebar queue panel for iPad landscape player, showing the current
/// playlist with a playing indicator on the active track.
struct QueuePanel: View {
    let songs: [Song]
    let currentSong: Song?
    let isPlaying: Bool
    let onSelect: @MainActor (Song) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.queue)
                .font(.miryam.display)
                .foregroundStyle(Color._miryamLabel)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            Divider()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(songs) { song in
                        queueRow(song)

                        if song.id != songs.last?.id {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
        }
        .frame(width: Layout.Player.queuePanelWidth)
        .background(Color._miryamSurface)
    }

    private func queueRow(_ song: Song) -> some View {
        let isCurrent = song.id == currentSong?.id

        return HStack(spacing: 10) {
            CachedAsyncImage(url: song.artworkURL(size: 88)) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color._miryamSurfaceSecondary)
                        .overlay(
                            Image(symbol: .musicNote)
                                .font(.caption2)
                                .foregroundStyle(Color._miryamSubtitle)
                        )
                @unknown default:
                    Color._miryamSurfaceSecondary
                }
            }
            .frame(width: 36, height: 36)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            VStack(alignment: .leading, spacing: 1) {
                Text(song.name)
                    .font(.miryam.bodySmall)
                    .foregroundStyle(isCurrent ? Color._miryamAccent : Color._miryamLabel)
                    .lineLimit(1)

                Text(song.artistName)
                    .font(.miryam.caption)
                    .foregroundStyle(Color._miryamLabelSecondary)
                    .lineLimit(1)
            }

            Spacer()

            if isCurrent, isPlaying {
                NowPlayingIndicator()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect(song)
        }
    }
}
