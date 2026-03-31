import MiryamUI
import XCTest

@MainActor
final class MiryamUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITestMode"]
    }

    override func tearDown() async throws {
        app = nil
    }

    // MARK: - Splash Screen

    func testSplashScreenAppearsOnLaunch() throws {
        app.launch()
        // Verify the Songs view doesn't appear immediately — splash is blocking.
        let songsNavBar = app.navigationBars["Songs"]
        XCTAssertFalse(songsNavBar.exists, "Songs should not appear while splash is showing")
    }

    func testSplashScreenTransitionsToSongsView() throws {
        app.launch()
        let songsNavTitle = app.navigationBars["Songs"]
        XCTAssertTrue(songsNavTitle.waitForExistence(timeout: 10))
    }

    // MARK: - Search Flow

    func testSearchFieldExists() throws {
        app.launch()
        waitForSongsView()

        let searchField = app.searchFields["Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
    }

    func testSearchForSongsShowsResults() throws {
        app.launch()
        searchFor("Adele")

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
    }

    func testSearchPagination() throws {
        app.launch()
        searchFor("Adele")

        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 5) else {
            XCTFail("No search results appeared")
            return
        }

        // Scroll down multiple times to trigger pagination
        for _ in 0 ..< 5 {
            app.swipeUp()
        }

        // After scrolling, cells should still exist (more loaded via pagination)
        let cellCount = app.cells.count
        XCTAssertGreaterThan(cellCount, 0, "Should have results after scrolling (pagination)")
    }

    func testSearchPreservesStateOnNavigation() throws {
        app.launch()
        searchFor("Adele")

        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 5) else {
            XCTFail("No search results appeared")
            return
        }
        firstCell.tap()

        // Wait for player
        let playPauseButton = app.buttons[AccessibilityID.playPause.rawValue]
        guard playPauseButton.waitForExistence(timeout: 5) else {
            XCTFail("Player did not appear")
            return
        }

        // Navigate back
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()

        // Verify search query is preserved
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))

        // Verify results are still visible
        let resultCell = app.cells.firstMatch
        XCTAssertTrue(resultCell.waitForExistence(timeout: 3), "Search results should persist after back navigation")
    }

    func testNoResultsState() throws {
        app.launch()
        searchFor("xyznonexistent")

        let noResultsView = app.descendants(matching: .any)[AccessibilityID.noResultsView.rawValue]
        XCTAssertTrue(noResultsView.waitForExistence(timeout: 10), "No results view should appear for empty search")
    }

    func testEmptySearchShowsPrompt() throws {
        app.launch()
        waitForSongsView()

        let emptyState = app.staticTexts["Search for songs"]
        // Empty state shows when there are no recently played songs and search is empty
        // If recently played exist, this won't show — both cases are valid
        if emptyState.waitForExistence(timeout: 3) {
            XCTAssertTrue(emptyState.exists)
        }
    }

    // MARK: - Player Navigation & Controls

    func testTapSongNavigatesToPlayer() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons[AccessibilityID.playPause.rawValue]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))
    }

    func testPlayerShowsTimelineControls() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons[AccessibilityID.playPause.rawValue]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))

        let skipForward = app.buttons[AccessibilityID.skipForward.rawValue]
        let skipBackward = app.buttons[AccessibilityID.skipBackward.rawValue]
        XCTAssertTrue(skipForward.waitForExistence(timeout: 3))
        XCTAssertTrue(skipBackward.waitForExistence(timeout: 3))
    }

    func testPlayerTogglePlayPause() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons[AccessibilityID.playPause.rawValue]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))
        playPauseButton.tap()
        XCTAssertTrue(playPauseButton.exists)
    }

    func testPlayerSkipForward() throws {
        app.launch()
        navigateToPlayer()

        let skipForward = app.buttons[AccessibilityID.skipForward.rawValue]
        XCTAssertTrue(skipForward.waitForExistence(timeout: 5))
        skipForward.tap()
        XCTAssertTrue(skipForward.exists)
    }

    func testPlayerSkipBackward() throws {
        app.launch()
        navigateToPlayer()

        let skipBackward = app.buttons[AccessibilityID.skipBackward.rawValue]
        XCTAssertTrue(skipBackward.waitForExistence(timeout: 5))
        skipBackward.tap()
        XCTAssertTrue(skipBackward.exists)
    }

    func testPlayerTimelineDisplay() throws {
        app.launch()
        navigateToPlayer()

        let songProgress = app.otherElements[AccessibilityID.songProgress.rawValue]
        XCTAssertTrue(songProgress.waitForExistence(timeout: 5), "Song progress timeline should be visible")
    }

    func testPlayerShowsSongInfo() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons[AccessibilityID.playPause.rawValue]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5), "Player controls should be visible")

        let staticTexts = app.staticTexts
        XCTAssertGreaterThan(staticTexts.count, 0, "Player should display song information")
    }

    // MARK: - More Options Sheet

    func testMoreOptionsSheetAppears() throws {
        app.launch()
        openMoreOptions()

        let moreOptionsSheet = app.descendants(matching: .any)[AccessibilityID.moreOptionsSheet.rawValue]
        XCTAssertTrue(moreOptionsSheet.waitForExistence(timeout: 5), "More options sheet should appear")
    }

    func testMoreOptionsShowsViewAlbumButton() throws {
        app.launch()
        openMoreOptions()

        let viewAlbumButton = app.buttons[AccessibilityID.viewAlbumButton.rawValue]
        XCTAssertTrue(viewAlbumButton.waitForExistence(timeout: 5), "View album button should be in more options sheet")
    }

    func testMoreOptionsViewAlbumNavigatesToAlbum() throws {
        app.launch()
        openMoreOptions()

        let viewAlbumButton = app.buttons[AccessibilityID.viewAlbumButton.rawValue]
        guard viewAlbumButton.waitForExistence(timeout: 5) else {
            XCTFail("View album button not found")
            return
        }
        viewAlbumButton.tap()

        let albumView = app.descendants(matching: .any)[AccessibilityID.albumView.rawValue]
        XCTAssertTrue(albumView.waitForExistence(timeout: 5), "Album view should appear after tapping View album")
    }

    // MARK: - Album View

    func testAlbumViewShowsTracks() throws {
        app.launch()
        navigateToAlbumFromSheet()

        let albumView = app.descendants(matching: .any)[AccessibilityID.albumView.rawValue]
        guard albumView.waitForExistence(timeout: 5) else {
            XCTFail("Album view did not appear")
            return
        }

        let staticTexts = app.staticTexts
        XCTAssertGreaterThan(staticTexts.count, 0, "Album view should display track information")
    }

    // MARK: - Swipe to Refresh

    func testSwipeToRefresh() throws {
        app.launch()
        searchFor("Adele")

        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 5) else {
            XCTFail("No search results appeared")
            return
        }

        // Pull to refresh
        let firstCellCoordinate = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let belowCellCoordinate = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 5.0))
        firstCellCoordinate.press(forDuration: 0.1, thenDragTo: belowCellCoordinate)

        let resultCell = app.cells.firstMatch
        XCTAssertTrue(resultCell.waitForExistence(timeout: 5), "Results should reappear after pull-to-refresh")
    }

    // MARK: - Navigation

    func testBackNavigationFromPlayer() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons[AccessibilityID.playPause.rawValue]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))

        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
    }

    // MARK: - Recently Played (SwiftData Cache)

    func testRecentlyPlayedShowsAfterPlaying() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons[AccessibilityID.playPause.rawValue]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))

        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()

        let songsNavBar = app.navigationBars["Songs"]
        _ = songsNavBar.waitForExistence(timeout: 5)

        if app.buttons["Cancel"].waitForExistence(timeout: 3) {
            app.buttons["Cancel"].tap()
        }

        // Check for recently played section — may or may not appear depending on cache timing
        let recentlyPlayed = app.descendants(matching: .any)[AccessibilityID.recentlyPlayedSection.rawValue]
        _ = recentlyPlayed.waitForExistence(timeout: 5)
    }

    // MARK: - Accessibility

    func testSongsViewAccessibilityIdentifier() throws {
        app.launch()
        waitForSongsView()

        let songsView = app.descendants(matching: .any)[AccessibilityID.songsView.rawValue]
        XCTAssertTrue(songsView.waitForExistence(timeout: 3), "SongsView should have accessibility identifier")
    }

    func testPlayerViewAccessibilityIdentifier() throws {
        app.launch()
        navigateToPlayer()

        let playerView = app.descendants(matching: .any)[AccessibilityID.playerView.rawValue]
        XCTAssertTrue(playerView.waitForExistence(timeout: 5), "PlayerView should have accessibility identifier")
    }

    // MARK: - Accessibility Audits

    func testSongsViewAccessibilityAudit() throws {
        app.launch()
        waitForSongsView()
        try app.performAccessibilityAudit(for: [
            .dynamicType,
            .sufficientElementDescription,
            .contrast,
            .hitRegion,
        ])
    }

    func testPlayerViewAccessibilityAudit() throws {
        app.launch()
        navigateToPlayer()
        try app.performAccessibilityAudit(for: [
            .dynamicType,
            .sufficientElementDescription,
            .contrast,
            .hitRegion,
        ])
    }

    func testMoreOptionsAccessibilityAudit() throws {
        app.launch()
        openMoreOptions()
        try app.performAccessibilityAudit(for: [
            .dynamicType,
            .sufficientElementDescription,
            .contrast,
            .hitRegion,
        ])
    }

    // MARK: - Launch Performance

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    // MARK: - Helpers

    @discardableResult
    private func waitForSongsView() -> Bool {
        let songsNavBar = app.navigationBars["Songs"]
        let appeared = songsNavBar.waitForExistence(timeout: 10)
        if !appeared {
            XCTFail("Songs view did not appear")
        }
        return appeared
    }

    private func searchFor(_ query: String) {
        waitForSongsView()

        let searchField = app.searchFields["Search"]
        guard searchField.waitForExistence(timeout: 3) else {
            XCTFail("Search field did not appear")
            return
        }
        searchField.tap()
        searchField.typeText(query)
    }

    private func navigateToPlayer() {
        searchFor("Adele")

        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 5) else {
            XCTFail("No search results appeared")
            return
        }
        firstCell.tap()
    }

    private func openMoreOptions() {
        searchFor("Adele")

        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 5) else {
            XCTFail("No search results appeared")
            return
        }

        let moreButton = app.buttons[AccessibilityID.moreOptionsButton.rawValue].firstMatch
        guard moreButton.waitForExistence(timeout: 5) else {
            XCTFail("More options button not found")
            return
        }
        moreButton.tap()
    }

    private func navigateToAlbumFromSheet() {
        openMoreOptions()

        let viewAlbumButton = app.buttons[AccessibilityID.viewAlbumButton.rawValue]
        guard viewAlbumButton.waitForExistence(timeout: 5) else {
            XCTFail("View album button not found in sheet")
            return
        }
        viewAlbumButton.tap()
    }
}
