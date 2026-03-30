import XCTest

final class MiryamUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Splash Screen

    @MainActor
    func testSplashScreenAppearsOnLaunch() throws {
        app.launch()
        let miryamText = app.staticTexts["Miryam"]
        XCTAssertTrue(miryamText.waitForExistence(timeout: 2))
    }

    @MainActor
    func testSplashScreenTransitionsToSongsView() throws {
        app.launch()
        let songsNavTitle = app.navigationBars["Songs"]
        XCTAssertTrue(songsNavTitle.waitForExistence(timeout: 5))
    }

    // MARK: - Search Flow

    @MainActor
    func testSearchFieldExists() throws {
        app.launch()
        let songsNavBar = app.navigationBars["Songs"]
        XCTAssertTrue(songsNavBar.waitForExistence(timeout: 5))

        let searchField = app.searchFields["Search songs..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
    }

    @MainActor
    func testSearchForSongsShowsResults() throws {
        app.launch()
        let songsNavBar = app.navigationBars["Songs"]
        XCTAssertTrue(songsNavBar.waitForExistence(timeout: 5))

        let searchField = app.searchFields["Search songs..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        searchField.typeText("Beatles")

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }

    @MainActor
    func testTapSongNavigatesToPlayer() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))
    }

    // MARK: - Player Controls

    @MainActor
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

    @MainActor
    func testPlayerTogglePlayPause() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))
        playPauseButton.tap()
        XCTAssertTrue(playPauseButton.exists)
    }

    // MARK: - Navigation

    @MainActor
    func testBackNavigationFromPlayer() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons["Play/Pause"]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))

        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()

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
