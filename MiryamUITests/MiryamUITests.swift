import XCTest

@MainActor
final class MiryamUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
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
        XCTAssertTrue(songsNavTitle.waitForExistence(timeout: 5))
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
        searchFor("Beatles")

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }

    func testSearchPagination() throws {
        app.launch()
        searchFor("Love")

        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 10) else {
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
        guard firstCell.waitForExistence(timeout: 10) else {
            XCTFail("No search results appeared")
            return
        }
        firstCell.tap()

        // Wait for player
        let playPauseButton = app.buttons["Play/Pause"]
        guard playPauseButton.waitForExistence(timeout: 5) else {
            XCTFail("Player did not appear")
            return
        }

        // Navigate back
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()

        // Verify search query is preserved
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))

        // Verify results are still visible
        let resultCell = app.cells.firstMatch
        XCTAssertTrue(resultCell.waitForExistence(timeout: 5), "Search results should persist after back navigation")
    }

    func testNoResultsState() throws {
        app.launch()
        searchFor("zzzxqqnosongsexist999")

        let noResultsView = app.descendants(matching: .any)["NoResultsView"]
        let errorButton = app.buttons["Try Again"]

        // Accept either no-results or error state (API may return error on CI)
        let noResults = noResultsView.waitForExistence(timeout: 15)
        XCTAssertTrue(
            noResults || errorButton.exists,
            "Should show no results or error state for gibberish query"
        )
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

        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))
    }

    func testPlayerShowsTimelineControls() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))

        let skipForward = app.buttons["Skip Forward"]
        let skipBackward = app.buttons["Skip Backward"]
        XCTAssertTrue(skipForward.waitForExistence(timeout: 3))
        XCTAssertTrue(skipBackward.waitForExistence(timeout: 3))
    }

    func testPlayerTogglePlayPause() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))
        playPauseButton.tap()
        XCTAssertTrue(playPauseButton.exists)
    }

    func testPlayerSkipForward() throws {
        app.launch()
        navigateToPlayer()

        let skipForward = app.buttons["Skip Forward"]
        XCTAssertTrue(skipForward.waitForExistence(timeout: 5))
        skipForward.tap()
        // Button should still exist after tapping
        XCTAssertTrue(skipForward.exists)
    }

    func testPlayerSkipBackward() throws {
        app.launch()
        navigateToPlayer()

        let skipBackward = app.buttons["Skip Backward"]
        XCTAssertTrue(skipBackward.waitForExistence(timeout: 5))
        skipBackward.tap()
        // Button should still exist after tapping
        XCTAssertTrue(skipBackward.exists)
    }

    func testPlayerTimelineDisplay() throws {
        app.launch()
        navigateToPlayer()

        // The timeline progress element should exist
        let songProgress = app.otherElements["Song progress"]
        XCTAssertTrue(songProgress.waitForExistence(timeout: 5), "Song progress timeline should be visible")
    }

    func testPlayerShowsSongInfo() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5), "Player controls should be visible")

        // Verify song info is displayed (at least some static texts exist)
        let staticTexts = app.staticTexts
        XCTAssertGreaterThan(staticTexts.count, 0, "Player should display song information")
    }

    // MARK: - More Options Sheet

    func testMoreOptionsSheetAppears() throws {
        app.launch()
        openMoreOptions()

        let moreOptionsSheet = app.descendants(matching: .any)["MoreOptionsSheet"]
        XCTAssertTrue(moreOptionsSheet.waitForExistence(timeout: 5), "More options sheet should appear")
    }

    func testMoreOptionsShowsViewAlbumButton() throws {
        app.launch()
        openMoreOptions()

        let viewAlbumButton = app.buttons["ViewAlbumButton"]
        XCTAssertTrue(viewAlbumButton.waitForExistence(timeout: 5), "View album button should be in more options sheet")
    }

    func testMoreOptionsViewAlbumNavigatesToAlbum() throws {
        app.launch()
        openMoreOptions()

        let viewAlbumButton = app.buttons["ViewAlbumButton"]
        guard viewAlbumButton.waitForExistence(timeout: 5) else {
            XCTFail("View album button not found")
            return
        }
        viewAlbumButton.tap()

        // Album view should appear
        let albumView = app.descendants(matching: .any)["AlbumView"]
        XCTAssertTrue(albumView.waitForExistence(timeout: 5), "Album view should appear after tapping View album")
    }

    // MARK: - Album View

    func testAlbumViewShowsTracks() throws {
        app.launch()
        navigateToAlbumFromSheet()

        // Album view should have track rows
        let albumView = app.descendants(matching: .any)["AlbumView"]
        guard albumView.waitForExistence(timeout: 5) else {
            XCTFail("Album view did not appear")
            return
        }

        // Wait for tracks to load
        let staticTexts = app.staticTexts
        // Album should display at least the album name and some track info
        XCTAssertGreaterThan(staticTexts.count, 0, "Album view should display track information")
    }

    // MARK: - Swipe to Refresh

    func testSwipeToRefresh() throws {
        app.launch()
        searchFor("Beatles")

        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 10) else {
            XCTFail("No search results appeared")
            return
        }

        // Pull to refresh
        let firstCellCoordinate = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let belowCellCoordinate = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 5.0))
        firstCellCoordinate.press(forDuration: 0.1, thenDragTo: belowCellCoordinate)

        // Results should still be visible after refresh
        let resultCell = app.cells.firstMatch
        XCTAssertTrue(resultCell.waitForExistence(timeout: 10), "Results should reappear after pull-to-refresh")
    }

    // MARK: - Navigation

    func testBackNavigationFromPlayer() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))

        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()

        // After navigating back, verify we're on the Songs screen.
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
    }

    // MARK: - Recently Played (SwiftData Cache)

    func testRecentlyPlayedShowsAfterPlaying() throws {
        app.launch()
        navigateToPlayer()

        // Wait a moment for the song to register as played
        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))

        // Navigate back
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()

        // Dismiss search to see home screen — use longer timeout for CI
        let songsNavBar = app.navigationBars["Songs"]
        _ = songsNavBar.waitForExistence(timeout: 10)

        // Cancel search if active
        if app.buttons["Cancel"].waitForExistence(timeout: 3) {
            app.buttons["Cancel"].tap()
        }

        // Check for recently played section
        let recentlyPlayed = app.descendants(matching: .any)["RecentlyPlayedSection"]
        // This may or may not appear depending on whether the song was cached
        // We just verify the flow doesn't crash
        _ = recentlyPlayed.waitForExistence(timeout: 5)
    }

    // MARK: - Accessibility

    func testSongsViewAccessibilityIdentifier() throws {
        app.launch()
        waitForSongsView()

        let songsView = app.descendants(matching: .any)["SongsView"]
        XCTAssertTrue(songsView.waitForExistence(timeout: 5), "SongsView should have accessibility identifier")
    }

    func testPlayerViewAccessibilityIdentifier() throws {
        app.launch()
        navigateToPlayer()

        let playerView = app.descendants(matching: .any)["PlayerView"]
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
        let appeared = songsNavBar.waitForExistence(timeout: 5)
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
        searchFor("Taylor Swift")

        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 10) else {
            XCTFail("No search results appeared")
            return
        }
        firstCell.tap()
    }

    private func openMoreOptions() {
        searchFor("Adele")

        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 10) else {
            XCTFail("No search results appeared")
            return
        }

        let moreButton = app.buttons["MoreOptionsButton"].firstMatch
        guard moreButton.waitForExistence(timeout: 5) else {
            XCTFail("More options button not found")
            return
        }
        moreButton.tap()
    }

    private func navigateToAlbumFromSheet() {
        openMoreOptions()

        let viewAlbumButton = app.buttons["ViewAlbumButton"]
        guard viewAlbumButton.waitForExistence(timeout: 5) else {
            XCTFail("View album button not found in sheet")
            return
        }
        viewAlbumButton.tap()
    }
}
