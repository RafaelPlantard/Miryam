import SwiftUI
import MiryamCore
import MiryamFeatures

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
            // Song info header
            songHeader

            Divider()
                .background(Color._miryamSurfaceSecondary)

            // Actions
            VStack(spacing: 0) {
                actionButton(
                    icon: "music.note.list",
                    title: "View Album"
                ) {
                    router.dismissSheet()
                    onViewAlbum()
                }

                Divider()
                    .background(Color._miryamSurfaceSecondary)
                    .padding(.leading, 56)

                actionButton(
                    icon: "square.and.arrow.up",
                    title: "Share"
                ) {
                    router.dismissSheet()
                }
            }

            Spacer()

            Button {
                router.dismissSheet()
            } label: {
                Text("Cancel")
                    .font(.miryam.bodyLarge)
                    .foregroundStyle(Color._miryamAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Song Header

    private var songHeader: some View {
        HStack(spacing: 12) {
            AsyncImage(url: song.artworkURL(size: 112)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color._miryamSurfaceSecondary)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundStyle(Color._miryamLabelSecondary)
                        )
                @unknown default:
                    Color._miryamSurfaceSecondary
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
        }
        .padding(20)
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
                    .font(.title3)
                    .foregroundStyle(Color._miryamIconPrimary)
                    .frame(width: 24)

                Text(title)
                    .font(.miryam.bodyLarge)
                    .foregroundStyle(Color._miryamLabel)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color._miryamLabelTertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .frame(minHeight: 44)
    }
}
