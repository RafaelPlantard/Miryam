import MiryamCore
import SwiftUI

/// Compact card for the recently played horizontal scroll.
public struct RecentlyPlayedCard: View {
    let song: Song

    public init(song: Song) {
        self.song = song
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: song.artworkURL(size: 200)) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color._miryamSurfaceSecondary)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.title2)
                                .foregroundStyle(Color._miryamLabelSecondary)
                        )
                @unknown default:
                    Color._miryamSurfaceSecondary
                }
            }
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(song.name)
                .font(.miryam.bodySmall)
                .foregroundStyle(Color._miryamLabel)
                .lineLimit(1)

            Text(song.artistName)
                .font(.miryam.bodySmall)
                .foregroundStyle(Color._miryamLabelSecondary)
                .lineLimit(1)
        }
        .frame(width: 140)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(song.name) by \(song.artistName)")
    }
}
