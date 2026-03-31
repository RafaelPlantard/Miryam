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
        .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: Layout.Songs.searchCornerRadius))
    }

    @ViewBuilder
    private var searchField: some View {
        let field = TextField(text: $query) {
            Text("Search")
                .foregroundStyle(Color._miryamLabelSecondary)
        }
        .foregroundStyle(Color._miryamLabel)
        .font(.miryam.bodyLarge)
        .accessibilityIdentifier(AccessibilityID.songsSearchField.rawValue)
        .accessibilityLabel("Search")

        #if os(tvOS)
            field
        #else
            field
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        #endif
    }
}
