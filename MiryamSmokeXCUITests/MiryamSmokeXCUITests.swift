import MiryamUI
import XCTest

@MainActor
final class MiryamSmokeXCUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITestMode"]
        app.launchEnvironment = UITestFixtureLoader.launchEnvironment()
    }

    override func tearDown() async throws {
        app = nil
    }

    func testLaunchTransitionsToSongsView() throws {
        launchApp()
        XCTAssertTrue(waitForSongsView(), "Songs view should appear after the splash screen")
    }

    func testSearchNavigatesToPlayer() throws {
        launchApp()
        navigateToPlayer()

        let playerView = app.descendants(matching: .any)[AccessibilityID.playerView.rawValue]
        XCTAssertTrue(playerView.waitForExistence(timeout: 5), "Player view should appear after selecting a song")
    }

    func testSearchNavigatesToAlbumFromMoreOptions() throws {
        launchApp()
        navigateToAlbumFromSheet()

        let albumView = app.descendants(matching: .any)[AccessibilityID.albumView.rawValue]
        XCTAssertTrue(albumView.waitForExistence(timeout: 5), "Album view should appear after the More Options flow")
    }

    private func launchApp() {
        app.launch()
        XCUIDevice.shared.orientation = .portrait
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

        let searchField = preferredSearchField()
        guard searchField.waitForExistence(timeout: 3) else {
            XCTFail("Search field did not appear")
            return
        }
        searchField.tap()
        searchField.typeText(query)
        let searchButton = app.keyboards.buttons["Search"].firstMatch
        if searchButton.waitForExistence(timeout: 1) {
            searchButton.tap()
        }
    }

    private func preferredSearchField() -> XCUIElement {
        let identifiedField = app.textFields[AccessibilityID.songsSearchField.rawValue].firstMatch
        if identifiedField.exists {
            return identifiedField
        }

        let searchField = app.searchFields["Search"].firstMatch
        if searchField.exists {
            return searchField
        }

        return app.textFields["Search"].firstMatch
    }

    private func navigateToPlayer() {
        searchFor("Adele")

        let firstResult = firstSearchResult()
        guard firstResult.waitForExistence(timeout: 5) else {
            XCTFail("No search results appeared")
            return
        }
        firstResult.tap()
    }

    private func openMoreOptions() {
        searchFor("Adele")

        let firstResult = firstSearchResult()
        guard firstResult.waitForExistence(timeout: 5) else {
            XCTFail("No search results appeared")
            return
        }

        let moreButton = app.buttons[AccessibilityID.moreOptionsButton.rawValue].firstMatch
        guard moreButton.waitForExistence(timeout: 5) else {
            XCTFail("More options button not found")
            return
        }
        moreButton.tap()

        let moreOptionsSheet = app.descendants(matching: .any)[AccessibilityID.moreOptionsSheet.rawValue]
        XCTAssertTrue(moreOptionsSheet.waitForExistence(timeout: 5), "More options sheet did not appear")
    }

    private func navigateToAlbumFromSheet() {
        openMoreOptions()

        let viewAlbumButton = app.descendants(matching: .any)[AccessibilityID.viewAlbumButton.rawValue]
        guard viewAlbumButton.waitForExistence(timeout: 5) else {
            XCTFail("View album button not found in sheet")
            return
        }
        viewAlbumButton.tap()
    }

    private func firstSearchResult() -> XCUIElement {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", "SongRow-")
        return app.descendants(matching: .any).matching(predicate).firstMatch
    }
}
