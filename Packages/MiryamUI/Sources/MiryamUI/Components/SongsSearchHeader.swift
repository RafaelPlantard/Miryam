import SwiftUI

struct SongsSearchHeader: View {
    @Binding var query: String

    var body: some View {
        HStack(spacing: Layout.Songs.searchIconSpacing) {
            Image(symbol: .magnifyingGlass)
                .font(.miryam.bodyLarge)
                .foregroundStyle(Color._miryamLabelSecondary)

            searchField
        }
        .padding(.horizontal, Layout.Songs.searchInnerHorizontalPadding)
        .frame(height: Layout.Songs.searchHeight)
        .background(Color._miryamSurfaceSecondary, in: RoundedRectangle(cornerRadius: Layout.Songs.searchCornerRadius))
    }

    @ViewBuilder
    private var searchField: some View {
        #if os(tvOS)
            TextField(text: $query) {
                Text(L10n.search)
                    .foregroundStyle(Color._miryamLabelSecondary)
            }
            .foregroundStyle(Color._miryamLabel)
            .font(.miryam.bodyLarge)
            .accessibilityIdentifier(AccessibilityID.songsSearchField.rawValue)
            .accessibilityLabel(Text(L10n.search))
        #elseif os(iOS) || os(visionOS)
            TextField(text: $query) {
                Text(L10n.search)
                    .foregroundStyle(Color._miryamLabelSecondary)
            }
            .foregroundStyle(Color._miryamLabel)
            .font(.miryam.bodyLarge)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .accessibilityIdentifier(AccessibilityID.songsSearchField.rawValue)
            .accessibilityLabel(Text(L10n.search))
        #else
            TextField(text: $query) {
                Text(L10n.search)
                    .foregroundStyle(Color._miryamLabelSecondary)
            }
            .foregroundStyle(Color._miryamLabel)
            .font(.miryam.bodyLarge)
            .accessibilityIdentifier(AccessibilityID.songsSearchField.rawValue)
            .accessibilityLabel(Text(L10n.search))
        #endif
    }
}
