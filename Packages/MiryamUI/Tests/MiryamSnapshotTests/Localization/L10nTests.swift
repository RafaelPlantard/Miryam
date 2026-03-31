import Testing
@testable import MiryamUI

@Suite("MiryamUI Localization")
struct L10nTests {
    @Test("Static resources resolve to the expected English copy")
    func staticResourcesResolve() {
        #expect(L10n.string(L10n.songs) == "Songs")
        #expect(L10n.string(L10n.search) == "Search")
        #expect(L10n.string(L10n.viewAlbum) == "View album")
    }

    @Test("Formatted helpers preserve their current English copy")
    func formattedHelpersResolve() {
        #expect(L10n.songArtistLabel(songName: "Bohemian Rhapsody", artistName: "Queen") == "Bohemian Rhapsody by Queen")
        #expect(L10n.moreOptions(for: "Bohemian Rhapsody") == "More options for Bohemian Rhapsody")
        #expect(L10n.viewAlbum(for: "A Night at the Opera") == "View album A Night at the Opera")
        #expect(L10n.trackCount(12) == "12 tracks")
        #expect(L10n.percentage(42) == "42%")
    }
}
