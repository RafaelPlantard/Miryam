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
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color._miryamLabelTertiary)
                .frame(width: 56, height: 5)
                .padding(.top, 5)

            // Song info header
            songHeader

            // Actions
            actionButton(
                icon: "music.note.list",
                title: "View album"
            ) {
                router.dismissSheet()
                onViewAlbum()
            }

            Spacer()
        }
        .background(Color._miryamSurface)
        .presentationDetents([.medium])
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
        .frame(height: 67)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Action Button

    private func actionButton(
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: 24)

                Text(title)
                    .font(.miryam.bodyLarge)
                    .foregroundStyle(Color._miryamLabel)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .frame(minHeight: 56)
    }
}
