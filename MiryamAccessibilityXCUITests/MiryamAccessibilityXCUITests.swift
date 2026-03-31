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
        app.launch()
        XCTAssertTrue(waitForSongsView(), "Songs view should appear before checking accessibility identifiers")

        let songsView = app.descendants(matching: .any)[AccessibilityID.songsView.rawValue]
        XCTAssertTrue(songsView.waitForExistence(timeout: 10), "SongsView should expose its accessibility identifier")
    }

    func testPlayerViewAccessibilityIdentifier() throws {
        app.launch()
        navigateToPlayer()

        let playerView = app.descendants(matching: .any)[AccessibilityID.playerView.rawValue]
        XCTAssertTrue(playerView.waitForExistence(timeout: 5), "PlayerView should expose its accessibility identifier")
    }

    func testSongsViewAccessibilityAudit() throws {
        app.launch()
        XCTAssertTrue(waitForSongsView(), "Songs view should appear before running the accessibility audit")

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
        ]) { issue in
            let description = issue.compactDescription
            let element = issue.element
            if description.contains("Contrast"), element?.elementType == .staticText { return true }
            if description.contains("no description"), element?.elementType == .image { return true }
            return false
        }
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

    func testAlbumViewAccessibilityAudit() throws {
        app.launch()
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
