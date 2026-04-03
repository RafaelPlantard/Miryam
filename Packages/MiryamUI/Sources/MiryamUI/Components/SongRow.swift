import MiryamCore
import SwiftUI

/// Reusable song list row with artwork, title, artist, and more button.
public struct SongRow: View {
    let song: Song
    let isPlaying: Bool
    var onTapped: (() -> Void)?
    var onViewAlbum: (() -> Void)?

    private var moreButtonHitTarget: CGFloat {
        #if os(tvOS)
            Layout.SongRow.moreButtonSize
        #else
            max(Layout.Player.minTapTarget, Layout.Player.secondaryControlSize)
        #endif
    }

    public init(
        song: Song,
        isPlaying: Bool = false,
        onTapped: (() -> Void)? = nil,
        onViewAlbum: (() -> Void)? = nil
    ) {
        self.song = song
        self.isPlaying = isPlaying
        self.onTapped = onTapped
        self.onViewAlbum = onViewAlbum
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
            .accessibilityLabel(L10n.songArtistLabel(songName: song.name, artistName: song.artistName))
            .accessibilityHint(Text(L10n.doubleTapToPlay))
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
                    .foregroundStyle(Color._miryamLabelSecondary)
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
        } else if let onViewAlbum {
            #if os(watchOS)
                Button(action: onViewAlbum) {
                    Image(symbol: .ellipsis)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color._miryamIconSecondary)
                        .frame(width: Layout.SongRow.moreButtonSize, height: Layout.SongRow.moreButtonSize)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(AccessibilityID.moreOptionsButton.rawValue)
                .accessibilityLabel(L10n.moreOptions(for: song.name))
            #else
                Menu {
                    Button {
                        onViewAlbum()
                    } label: {
                        Label(L10n.string(L10n.viewAlbum), systemImage: "music.note.list")
                    }
                } label: {
                    Image(symbol: .ellipsis)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color._miryamIconSecondary)
                        .frame(width: Layout.SongRow.moreButtonSize, height: Layout.SongRow.moreButtonSize)
                        .background(Color.black.opacity(0.001), in: Circle())
                        .frame(width: moreButtonHitTarget, height: moreButtonHitTarget)
                        .contentShape(Rectangle())
                }
                .frame(width: moreButtonHitTarget, height: moreButtonHitTarget)
                .contentShape(Rectangle())
                .accessibilityIdentifier(AccessibilityID.moreOptionsButton.rawValue)
                .accessibilityLabel(L10n.moreOptions(for: song.name))
                .accessibilityHint(Text(L10n.doubleTapForAdditionalActions))
            #endif
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
