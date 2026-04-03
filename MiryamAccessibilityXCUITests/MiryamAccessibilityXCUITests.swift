import MiryamUI
import XCTest

@MainActor
final class MiryamAccessibilityXCUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDown() async throws {
        if let app, app.state != .notRunning {
            app.terminate()
        }
        app = nil
    }

    func testSplashAccessibilityAudit() throws {
        try runAccessibilityAudit(for: .splash)
    }

    func testSongsAccessibilityAudit() throws {
        try runAccessibilityAudit(for: .songs)
    }

    func testPlayerAccessibilityAudit() throws {
        try runAccessibilityAudit(for: .player)
    }

    func testMoreOptionsAccessibilityAudit() throws {
        try runAccessibilityAudit(for: .moreOptions)
    }

    func testAlbumAccessibilityAudit() throws {
        try runAccessibilityAudit(for: .album)
    }

    private func runAccessibilityAudit(for screen: AccessibilityScreen) throws {
        launchApp(for: screen)
        prepareScreen(for: screen)

        guard let contract = AccessibilityContracts.contract(for: screen, platform: currentRuntimePlatform()) else {
            XCTFail("Missing runtime accessibility contract for \(screen.rawValue)")
            return
        }

        let root = app.descendants(matching: .any)[contract.rootIdentifier]
        XCTAssertTrue(
            root.waitForExistence(timeout: 5),
            "\(contract.description) should expose root identifier \(contract.rootIdentifier)"
        )

        for expectation in contract.runtimeRequiredElements {
            assertExpectation(expectation, in: contract)
        }

        try app.performAccessibilityAudit(
            for: contract.auditKinds.xcuiTypes
        ) { [contract] issue in
            let shouldSuppress = self.shouldSuppress(issue, for: contract)
            if !shouldSuppress {
                self.log(issue, for: contract)
            }
            return shouldSuppress
        }
    }

    private func launchApp(for screen: AccessibilityScreen) {
        var arguments = ["-UITestMode"]
        if screen == .splash {
            arguments.append("-UITestHoldSplash")
        }

        app.launchArguments = arguments
        app.launch()
        XCUIDevice.shared.orientation = .portrait
    }

    private func prepareScreen(for screen: AccessibilityScreen) {
        switch screen {
        case .splash:
            break
        case .songs:
            XCTAssertTrue(waitForSongsView(), "Songs view should appear before running the accessibility audit")
            XCTAssertTrue(
                firstSongRow().waitForExistence(timeout: 5),
                "At least one song row should be available for the Songs accessibility audit"
            )
        case .player:
            openFirstSong()
        case .moreOptions:
            openMoreOptions()
        case .album:
            navigateToAlbumFromSheet()
        case .watchNowPlaying, .watchAlbum:
            XCTFail("Watch accessibility contracts are validated by Swift Testing, not XCUITest")
        }
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

    private func openFirstSong() {
        XCTAssertTrue(waitForSongsView(), "Songs view should appear before navigating to the player")

        let row = firstSongRow()
        guard row.waitForExistence(timeout: 5) else {
            XCTFail("No song row appeared")
            return
        }

        row.tap()
    }

    private func openMoreOptions() {
        // Navigate to the player first — on iPhone the toolbar ellipsis presents the sheet.
        openFirstSong()

        let playerView = app.descendants(matching: .any)[AccessibilityID.playerView.rawValue]
        guard playerView.waitForExistence(timeout: 5) else {
            XCTFail("Player view did not appear")
            return
        }

        let moreButton = app.buttons[AccessibilityID.moreOptionsButton.rawValue].firstMatch
        guard moreButton.waitForExistence(timeout: 5) else {
            XCTFail("More options button not found in player toolbar")
            return
        }

        moreButton.tap()

        let moreOptionsSheet = app.descendants(matching: .any)[AccessibilityID.moreOptionsSheet.rawValue]
        XCTAssertTrue(moreOptionsSheet.waitForExistence(timeout: 5), "More options sheet did not appear")
    }

    private func navigateToAlbumFromSheet() {
        openMoreOptions()

        let viewAlbumButton = app.buttons[AccessibilityID.viewAlbumButton.rawValue].firstMatch
        guard viewAlbumButton.waitForExistence(timeout: 5) else {
            XCTFail("View album button not found in sheet")
            return
        }

        viewAlbumButton.tap()

        let albumView = app.descendants(matching: .any)[AccessibilityID.albumView.rawValue]
        XCTAssertTrue(albumView.waitForExistence(timeout: 5), "Album view did not appear")
    }

    private func firstSongRow() -> XCUIElement {
        resolveElement(
            for: AccessibilityElementExpectation(
                locator: .idPrefix("SongRow-"),
                role: .button,
                labelRule: .nonEmpty,
                interactive: true
            )
        )
    }

    private func resolveElement(for expectation: AccessibilityElementExpectation) -> XCUIElement {
        let query = baseQuery(for: expectation.role)
            .matching(predicate(for: expectation.locator))

        if let labelPredicate = labelPredicate(for: expectation.labelRule) {
            return query.matching(labelPredicate).firstMatch
        }

        return query.firstMatch
    }

    private func baseQuery(for role: AccessibilityElementRole) -> XCUIElementQuery {
        switch role {
        case .button:
            app.buttons
        case .textField:
            app.descendants(matching: .textField)
        default:
            app.descendants(matching: .any)
        }
    }

    private func predicate(for locator: AccessibilityLocator) -> NSPredicate {
        switch locator {
        case let .id(identifier):
            NSPredicate(format: "identifier == %@", identifier)
        case let .idPrefix(prefix):
            NSPredicate(format: "identifier BEGINSWITH %@", prefix)
        }
    }

    private func labelPredicate(for rule: AccessibilityLabelRule?) -> NSPredicate? {
        guard let rule else { return nil }

        switch rule {
        case let .exact(value):
            return NSPredicate(format: "label == %@", value)
        case let .prefix(value):
            return NSPredicate(format: "label BEGINSWITH %@", value)
        case .nonEmpty:
            return NSPredicate(format: "label != ''")
        }
    }

    private func assertExpectation(
        _ expectation: AccessibilityElementExpectation,
        in contract: AccessibilityScreenContract
    ) {
        let element = resolveElement(for: expectation)
        let exists = element.waitForExistence(timeout: 5)
        XCTAssertTrue(
            exists,
            "\(contract.description) should expose \(expectation.locator.description)\(diagnosticSummary(for: expectation))"
        )

        guard exists else { return }

        if expectation.role != .any {
            XCTAssertTrue(
                matchesRole(element.elementType, expected: expectation.role),
                "\(contract.description) expected \(expectation.locator.description) to be \(expectation.role.rawValue) but got \(element.elementType)"
            )
        }

        guard let labelRule = expectation.labelRule else { return }

        let label = element.label.trimmingCharacters(in: .whitespacesAndNewlines)
        switch labelRule {
        case let .exact(value):
            XCTAssertEqual(
                label,
                value,
                "\(contract.description) expected \(expectation.locator.description) label to equal '\(value)'"
            )
        case let .prefix(value):
            XCTAssertTrue(
                label.hasPrefix(value),
                "\(contract.description) expected \(expectation.locator.description) label to start with '\(value)' but got '\(label)'"
            )
        case .nonEmpty:
            XCTAssertFalse(
                label.isEmpty,
                "\(contract.description) expected \(expectation.locator.description) label to be non-empty"
            )
        }
    }

    private func diagnosticSummary(for expectation: AccessibilityElementExpectation) -> String {
        let locatorPredicate = predicate(for: expectation.locator)
        let anyQuery = app.descendants(matching: .any).matching(locatorPredicate)
        let buttonQuery = app.buttons.matching(locatorPredicate)

        guard anyQuery.count > 0 || buttonQuery.count > 0 else {
            return " (diagnostics: no matching descendants found)"
        }

        let samples = (0 ..< min(anyQuery.count, 3)).map { index in
            let element = anyQuery.element(boundBy: index)
            return "\(element.elementType)[id='\(element.identifier)', label='\(element.label)']"
        }

        return " (diagnostics: any=\(anyQuery.count), buttons=\(buttonQuery.count), samples=\(samples.joined(separator: "; ")))"
    }

    private func currentRuntimePlatform() -> AccessibilityPlatform {
        let window = app.windows.firstMatch
        guard window.waitForExistence(timeout: 5) else { return .iphone }
        return window.frame.width >= 700 ? .ipad : .iphone
    }

    private func matchesRole(
        _ elementType: XCUIElement.ElementType,
        expected role: AccessibilityElementRole
    ) -> Bool {
        switch role {
        case .any:
            true
        case .container:
            [.other, .group, .scrollView, .table, .collectionView].contains(elementType)
        case .button:
            elementType == .button
        case .textField:
            [.textField, .searchField].contains(elementType)
        case .staticText:
            elementType == .staticText
        case .image:
            elementType == .image
        }
    }

    private func shouldSuppress(
        _ issue: XCUIAccessibilityAuditIssue,
        for contract: AccessibilityScreenContract
    ) -> Bool {
        let description = issue.compactDescription
        let elementRole: AccessibilityElementRole? = if let element = issue.element {
            role(for: element.elementType)
        } else {
            nil
        }

        return contract.allowedSuppressions.contains { suppression in
            guard description.contains(suppression.descriptionContains) else { return false }
            guard let expectedRole = suppression.role else { return true }
            return elementRole == expectedRole
        }
    }

    private func log(
        _ issue: XCUIAccessibilityAuditIssue,
        for contract: AccessibilityScreenContract
    ) {
        let element = issue.element
        let identifier = element?.identifier ?? "<none>"
        let label = element?.label ?? "<none>"
        print(
            """
            Accessibility audit issue for \(contract.description):
            description: \(issue.compactDescription)
            identifier: \(identifier)
            label: \(label)
            type: \(String(describing: element?.elementType))
            """
        )
    }

    private func role(for elementType: XCUIElement.ElementType) -> AccessibilityElementRole {
        switch elementType {
        case .button:
            .button
        case .textField, .searchField:
            .textField
        case .staticText:
            .staticText
        case .image:
            .image
        default:
            .container
        }
    }
}

private extension AccessibilityAuditKind {
    var xcuiType: XCUIAccessibilityAuditType {
        switch self {
        case .dynamicType:
            .dynamicType
        case .sufficientElementDescription:
            .sufficientElementDescription
        case .contrast:
            .contrast
        case .hitRegion:
            .hitRegion
        }
    }
}

private extension [AccessibilityAuditKind] {
    var xcuiTypes: XCUIAccessibilityAuditType {
        reduce(into: XCUIAccessibilityAuditType()) { partialResult, kind in
            partialResult.formUnion(kind.xcuiType)
        }
    }
}
