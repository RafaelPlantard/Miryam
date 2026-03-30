import MiryamCore
import SwiftUI

/// Reusable song list row with artwork, title, artist, and more button.
public struct SongRow: View {
    let song: Song
    var onTapped: (() -> Void)?
    var onMoreTapped: (() -> Void)?

    public init(
        song: Song,
        onTapped: (() -> Void)? = nil,
        onMoreTapped: (() -> Void)? = nil
    ) {
        self.song = song
        self.onTapped = onTapped
        self.onMoreTapped = onMoreTapped
    }

    public var body: some View {
        HStack(spacing: 16) {
            Button {
                onTapped?()
            } label: {
                HStack(spacing: 16) {
                    AsyncImage(url: song.artworkURL(size: 104)) { phase in
                        switch phase {
                        case let .success(image):
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
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if let onMoreTapped {
                Button(action: onMoreTapped) {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundStyle(Color._miryamSubtitle)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("More options for \(song.name)")
            }
        }
        .padding(.vertical, 8)
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
