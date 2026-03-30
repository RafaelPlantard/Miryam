import SwiftUI
import MiryamCore

/// Reusable song list row with artwork, title, artist, and more button.
public struct SongRow: View {
    let song: Song
    var onMoreTapped: (() -> Void)?

    public init(song: Song, onMoreTapped: (() -> Void)? = nil) {
        self.song = song
        self.onMoreTapped = onMoreTapped
    }

    public var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: song.artworkURL(size: 104)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    albumPlaceholder
                case .empty:
                    albumPlaceholder
                        .overlay(ProgressView().tint(Color._miryamSubtitle))
                @unknown default:
                    albumPlaceholder
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(song.name)
                    .font(.miryam.bodyLarge)
                    .foregroundStyle(Color._miryamLabel)
                    .lineLimit(1)

                Text(song.artistName)
                    .font(.miryam.caption)
                    .foregroundStyle(Color._miryamSubtitle)
                    .lineLimit(1)
            }

            Spacer()

            if let onMoreTapped {
                Button(action: onMoreTapped) {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundStyle(Color._miryamSubtitle)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("More options for \(song.name)")
            }
        }
        .padding(.vertical, 8)
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
                    .foregroundStyle(Color._miryamSubtitle)
            )
    }
}
