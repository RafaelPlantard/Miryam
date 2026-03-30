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
        let songsNavBar = app.navigationBars["Songs"]
        XCTAssertTrue(songsNavBar.waitForExistence(timeout: 5))

        let searchField = app.searchFields["Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
    }

    func testSearchForSongsShowsResults() throws {
        app.launch()
        let songsNavBar = app.navigationBars["Songs"]
        XCTAssertTrue(songsNavBar.waitForExistence(timeout: 5))

        let searchField = app.searchFields["Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        searchField.typeText("Beatles")

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }

    func testTapSongNavigatesToPlayer() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))
    }

    // MARK: - Player Controls

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
        // The search field confirms we returned to SongsView.
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
    }

    // MARK: - Launch Performance

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    // MARK: - Helpers

    private func navigateToPlayer() {
        let songsNavBar = app.navigationBars["Songs"]
        guard songsNavBar.waitForExistence(timeout: 5) else {
            XCTFail("Songs view did not appear")
            return
        }

        let searchField = app.searchFields["Search"]
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
