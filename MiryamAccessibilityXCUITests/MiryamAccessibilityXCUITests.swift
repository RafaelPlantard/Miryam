import MiryamUI
import XCTest

@MainActor
final class MiryamAccessibilityXCUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITestMode"]
    }

    override func tearDown() async throws {
        app = nil
    }

    func testSongsViewAccessibilityIdentifier() throws {
        launchApp()
        XCTAssertTrue(waitForSongsView(), "Songs view should appear before checking accessibility identifiers")

        let songsView = app.descendants(matching: .any)[AccessibilityID.songsView.rawValue]
        XCTAssertTrue(songsView.waitForExistence(timeout: 10), "SongsView should expose its accessibility identifier")
    }

    func testPlayerViewAccessibilityIdentifier() throws {
        launchApp()
        navigateToPlayer()

        let playerView = app.descendants(matching: .any)[AccessibilityID.playerView.rawValue]
        XCTAssertTrue(playerView.waitForExistence(timeout: 5), "PlayerView should expose its accessibility identifier")
    }

    func testSongsViewAccessibilityAudit() throws {
        launchApp()
        XCTAssertTrue(waitForSongsView(), "Songs view should appear before running the accessibility audit")

        try app.performAccessibilityAudit(for: [
            .dynamicType,
            .sufficientElementDescription,
            .contrast,
            .hitRegion,
        ])
    }

    func testPlayerViewAccessibilityAudit() throws {
        launchApp()
        navigateToPlayer()

        try app.performAccessibilityAudit(for: [
            .dynamicType,
            .sufficientElementDescription,
            .contrast,
            .hitRegion,
        ]) { issue in
            let description = issue.compactDescription
            let element = issue.element
            if description.contains("Contrast"), element?.elementType == .staticText { return true }
            if description.contains("no description"), element?.elementType == .image { return true }
            return false
        }
    }

    func testMoreOptionsAccessibilityAudit() throws {
        launchApp()
        openMoreOptions()

        try app.performAccessibilityAudit(for: [
            .dynamicType,
            .sufficientElementDescription,
            .contrast,
            .hitRegion,
        ])
    }

    func testAlbumViewAccessibilityAudit() throws {
        launchApp()
        navigateToAlbumFromSheet()

        let albumView = app.descendants(matching: .any)[AccessibilityID.albumView.rawValue]
        guard albumView.waitForExistence(timeout: 5) else {
            XCTFail("Album view did not appear")
            return
        }

        try app.performAccessibilityAudit(for: [
            .dynamicType,
            .sufficientElementDescription,
            .contrast,
            .hitRegion,
        ])
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
        XCTAssertTrue(waitForSongsView(), "Songs view should appear before searching")

        let searchField = app.textFields[AccessibilityID.songsSearchField.rawValue].firstMatch
            .exists
            ? app.textFields[AccessibilityID.songsSearchField.rawValue].firstMatch
            : (app.searchFields["Search"].firstMatch.exists
                ? app.searchFields["Search"].firstMatch
                : app.textFields["Search"].firstMatch)
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
