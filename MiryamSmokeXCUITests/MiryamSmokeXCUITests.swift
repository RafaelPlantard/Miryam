import MiryamUI
import XCTest

@MainActor
final class MiryamSmokeXCUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITestMode"]
    }

    override func tearDown() async throws {
        app = nil
    }

    func testLaunchTransitionsToSongsView() throws {
        app.launch()
        XCTAssertTrue(waitForSongsView(), "Songs view should appear after the splash screen")
    }

    func testSearchNavigatesToPlayer() throws {
        app.launch()
        navigateToPlayer()

        let playPauseButton = app.buttons[AccessibilityID.playPause.rawValue]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))
    }

    func testSearchNavigatesToAlbumFromMoreOptions() throws {
        app.launch()
        navigateToAlbumFromSheet()

        let albumView = app.descendants(matching: .any)[AccessibilityID.albumView.rawValue]
        XCTAssertTrue(albumView.waitForExistence(timeout: 5), "Album view should appear after the More Options flow")
    }

    @discardableResult
    private func waitForSongsView() -> Bool {
        let songsNavBar = app.navigationBars["Songs"]
        if songsNavBar.waitForExistence(timeout: 5) { return true }

        let songsView = app.descendants(matching: .any)[AccessibilityID.songsView.rawValue]
        let appeared = songsView.waitForExistence(timeout: 5)
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
