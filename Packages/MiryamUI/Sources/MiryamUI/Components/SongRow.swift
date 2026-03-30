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
            HStack(spacing: 16) {
                CachedAsyncImage(url: song.artworkURL(size: 104)) { phase in
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
                .frame(width: Layout.SongRow.thumbnailSize, height: Layout.SongRow.thumbnailSize)
                .clipShape(RoundedRectangle(cornerRadius: Layout.SongRow.thumbnailCornerRadius))

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
            .onTapGesture { onTapped?() }
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel("\(song.name) by \(song.artistName)")
            .accessibilityHint("Double tap to play")

            if let onMoreTapped {
                Button(action: onMoreTapped) {
                    Image(symbol: .ellipsis)
                        .font(.body)
                        .foregroundStyle(Color._miryamIconSecondary)
                        .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(AccessibilityID.moreOptionsButton.rawValue)
                .accessibilityLabel("More options for \(song.name)")
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.songRow(id: song.id))
    }

    private var albumPlaceholder: some View {
        RoundedRectangle(cornerRadius: Layout.SongRow.thumbnailCornerRadius)
            .fill(Color._miryamSurfaceSecondary)
            .overlay(
                Image(symbol: .musicNote)
                    .foregroundStyle(Color._miryamSubtitle)
            )
    }
}
