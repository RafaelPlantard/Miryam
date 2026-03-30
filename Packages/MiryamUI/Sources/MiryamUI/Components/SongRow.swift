import SwiftUI
import MiryamCore

/// Reusable song list row with artwork, title, and artist.
public struct SongRow: View {
    let song: Song

    public init(song: Song) {
        self.song = song
    }

    public var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: song.artworkURL(size: 112)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    albumPlaceholder
                case .empty:
                    albumPlaceholder
                        .overlay(ProgressView().tint(Color._miryamLabelSecondary))
                @unknown default:
                    albumPlaceholder
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 8))

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
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(song.name) by \(song.artistName)")
        .accessibilityHint("Double tap to play")
    }

    private var albumPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color._miryamSurfaceSecondary)
            .overlay(
                Image(systemName: "music.note")
                    .foregroundStyle(Color._miryamLabelSecondary)
            )
    }
}
