import MiryamCore
import MiryamFeatures
import SwiftUI

public struct MoreOptionsView: View {
    let song: Song
    @Environment(Router.self) private var router
    private let onViewAlbum: @MainActor () -> Void

    public init(song: Song, onViewAlbum: @escaping @MainActor () -> Void) {
        self.song = song
        self.onViewAlbum = onViewAlbum
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Grabber
            RoundedRectangle(cornerRadius: Layout.MoreOptions.grabberCornerRadius)
                .fill(Color._miryamLabelTertiary)
                .frame(width: Layout.MoreOptions.grabberWidth, height: Layout.MoreOptions.grabberHeight)
                .padding(.top, 5)

            // Song info header
            songHeader

            // Actions
            actionButton(
                icon: .musicNoteList,
                title: "View album",
                identifier: AccessibilityID.viewAlbumButton.rawValue
            ) {
                router.dismissSheet()
                onViewAlbum()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.moreOptionsSheet.rawValue)
        .background(Color._miryamSurface)
        .presentationDetents([.height(Layout.MoreOptions.sheetHeight)])
        .presentationCornerRadius(16)
    }

    // MARK: - Song Header

    private var songHeader: some View {
        VStack(spacing: 4) {
            Text(song.name)
                .font(.miryam.display)
                .foregroundStyle(Color._miryamLabel)
                .lineLimit(1)

            Text(song.artistName)
                .font(.miryam.bodySmall)
                .foregroundStyle(Color._miryamLabel)
                .lineLimit(1)
        }
        .frame(height: Layout.MoreOptions.songHeaderHeight)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Action Button

    private func actionButton(
        icon: SFSymbol,
        title: String,
        identifier: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(symbol: icon)
                    .font(.body)
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: Layout.MoreOptions.iconFrameWidth)

                Text(title)
                    .font(.miryam.bodyLarge)
                    .foregroundStyle(Color._miryamLabel)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(minHeight: Layout.MoreOptions.actionButtonMinHeight)
        .accessibilityIdentifier(identifier ?? title)
    }
}
