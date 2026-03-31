import MiryamCore
import SwiftUI

/// Reusable song list row with artwork, title, artist, and more button.
public struct SongRow: View {
    let song: Song
    let isPlaying: Bool
    var onTapped: (() -> Void)?
    var onMoreTapped: (() -> Void)?

    private var moreButtonHitTarget: CGFloat {
        max(Layout.Player.minTapTarget, Layout.Player.secondaryControlSize)
    }

    public init(
        song: Song,
        isPlaying: Bool = false,
        onTapped: (() -> Void)? = nil,
        onMoreTapped: (() -> Void)? = nil
    ) {
        self.song = song
        self.isPlaying = isPlaying
        self.onTapped = onTapped
        self.onMoreTapped = onMoreTapped
    }

    public var body: some View {
        HStack(spacing: Layout.SongRow.contentSpacing) {
            rowAction

            trailingAccessory
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: Layout.SongRow.rowHeight)
    }

    @ViewBuilder
    private var rowAction: some View {
        if let onTapped {
            Button(action: onTapped) {
                rowContent
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel("\(song.name) by \(song.artistName)")
            .accessibilityHint("Double tap to play")
            .accessibilityIdentifier(AccessibilityID.songRow(id: song.id))
        } else {
            rowContent
        }
    }

    private var rowContent: some View {
        HStack(spacing: Layout.SongRow.contentSpacing) {
            artwork

            VStack(alignment: .leading, spacing: Layout.SongRow.textSpacing) {
                Text(song.name)
                    .font(.miryam.bodyLarge)
                    .foregroundStyle(Color._miryamLabel)
                    .lineLimit(1)

                Text(song.artistName)
                    .font(.miryam.caption)
                    .foregroundStyle(Color._miryamSubtitle)
                    .lineLimit(1)
            }
            .accessibilityHidden(true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: Layout.SongRow.rowHeight)
        .contentShape(Rectangle())
    }

    private var artwork: some View {
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
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var trailingAccessory: some View {
        if isPlaying {
            NowPlayingIndicator()
                .frame(width: Layout.Player.minTapTarget, height: Layout.Player.minTapTarget)
                .accessibilityHidden(true)
        } else if let onMoreTapped {
            Button(action: onMoreTapped) {
                Image(symbol: .ellipsis)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color._miryamIconSecondary)
                    .frame(width: Layout.SongRow.moreButtonSize, height: Layout.SongRow.moreButtonSize)
                    .background(Color.black.opacity(0.001), in: Circle())
                    .frame(width: moreButtonHitTarget, height: moreButtonHitTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(width: moreButtonHitTarget, height: moreButtonHitTarget)
            .contentShape(Rectangle())
            .accessibilityIdentifier(AccessibilityID.moreOptionsButton.rawValue)
            .accessibilityLabel("More options for \(song.name)")
            .accessibilityHint("Double tap for additional actions")
        }
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
