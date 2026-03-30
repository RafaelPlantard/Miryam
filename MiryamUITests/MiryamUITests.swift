import XCTest

final class MiryamUITests: XCTestCase {

    private var app: XCUIApplication!

    @MainActor
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Splash Screen

    @MainActor
    func testSplashScreenAppearsOnLaunch() throws {
        // The splash screen should show "Miryam" text
        let miryamText = app.staticTexts["Miryam"]
        // Splash auto-dismisses after 2s, so check immediately
        XCTAssertTrue(miryamText.waitForExistence(timeout: 2))
    }

    @MainActor
    func testSplashScreenTransitionsToSongsView() throws {
        // Wait for splash to dismiss and Songs view to appear
        let songsNavTitle = app.navigationBars["Songs"]
        XCTAssertTrue(songsNavTitle.waitForExistence(timeout: 5))
    }

    // MARK: - Search Flow

    @MainActor
    func testSearchFieldExists() throws {
        // Wait for songs view
        let songsNavBar = app.navigationBars["Songs"]
        XCTAssertTrue(songsNavBar.waitForExistence(timeout: 5))

        // Search field should be accessible
        let searchField = app.searchFields["Search songs..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
    }

    @MainActor
    func testSearchForSongsShowsResults() throws {
        let songsNavBar = app.navigationBars["Songs"]
        XCTAssertTrue(songsNavBar.waitForExistence(timeout: 5))

        // Tap search field and type a query
        let searchField = app.searchFields["Search songs..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        searchField.typeText("Beatles")

        // Wait for results to load (network call + debounce)
        // List cells should appear
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }

    @MainActor
    func testTapSongNavigatesToPlayer() throws {
        let songsNavBar = app.navigationBars["Songs"]
        XCTAssertTrue(songsNavBar.waitForExistence(timeout: 5))

        // Search for songs
        let searchField = app.searchFields["Search songs..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        searchField.typeText("Adele")

        // Wait for results
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))

        // Tap first result to navigate to player
        firstCell.tap()

        // Player should show play/pause button
        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))
    }

    // MARK: - Player Controls

    @MainActor
    func testPlayerShowsTimelineControls() throws {
        navigateToPlayer()

        // Timeline elements should be visible
        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))

        // Skip buttons
        let skipForward = app.buttons["Skip Forward"]
        let skipBackward = app.buttons["Skip Backward"]
        XCTAssertTrue(skipForward.waitForExistence(timeout: 3))
        XCTAssertTrue(skipBackward.waitForExistence(timeout: 3))
    }

    @MainActor
    func testPlayerTogglePlayPause() throws {
        navigateToPlayer()

        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))

        // Tap to toggle
        playPauseButton.tap()

        // Button should still exist (toggled state)
        XCTAssertTrue(playPauseButton.exists)
    }

    // MARK: - Navigation

    @MainActor
    func testBackNavigationFromPlayer() throws {
        navigateToPlayer()

        // Wait for player to load
        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))

        // Navigate back
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()

        // Should be back on Songs view
        let songsNavBar = app.navigationBars["Songs"]
        XCTAssertTrue(songsNavBar.waitForExistence(timeout: 3))
    }

    // MARK: - Launch Performance

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    // MARK: - Helpers

    @MainActor
    private func navigateToPlayer() {
        let songsNavBar = app.navigationBars["Songs"]
        guard songsNavBar.waitForExistence(timeout: 5) else {
            XCTFail("Songs view did not appear")
            return
        }

        let searchField = app.searchFields["Search songs..."]
        guard searchField.waitForExistence(timeout: 3) else {
            XCTFail("Search field did not appear")
            return
        }
        searchField.tap()
        searchField.typeText("Taylor Swift")

        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 10) else {
            XCTFail("No search results appeared")
            return
        }
        firstCell.tap()
    }
}
