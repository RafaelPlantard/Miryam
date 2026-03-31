import Testing

@Suite("Accessibility Contracts")
struct AccessibilityContractTests {
    @Test("Every covered platform and screen has a contract")
    func coverageIsComplete() {
        let coverage = Set(AccessibilityContracts.all.map(\.coverageKey))
        #expect(coverage == AccessibilityContracts.expectedCoverage)
    }

    @Test("Contracts do not duplicate locators within a screen", arguments: AccessibilityContracts.all)
    func contractsDoNotDuplicateLocators(contract: AccessibilityScreenContract) {
        let uniqueLocators = Set(contract.allLocatorKeys)
        #expect(uniqueLocators.count == contract.allLocatorKeys.count)
    }

    @Test("Runtime assertions stay within the documented contract", arguments: AccessibilityContracts.all)
    func runtimeAssertionsStayWithinDocumentedContract(contract: AccessibilityScreenContract) {
        let documentedLocators = Set(contract.allLocatorKeys)
        let runtimeLocators = Set(contract.runtimeLocatorKeys)
        #expect(runtimeLocators.isSubset(of: documentedLocators))
    }

    @Test(
        "Interactive elements require human-readable label rules",
        arguments: AccessibilityContracts.all.flatMap(\.requiredElements)
    )
    func interactiveElementsRequireLabels(expectation: AccessibilityElementExpectation) {
        #expect(expectation.hasHumanReadableLabelRule)
    }

    @Test("Challenge-critical elements are represented", arguments: AccessibilityContracts.all)
    func challengeCriticalElementsAreRepresented(contract: AccessibilityScreenContract) {
        let expected = AccessibilityContracts.challengeCriticalLocators[contract.coverageKey] ?? []
        let actual = Set(contract.allLocatorKeys)
        #expect(expected.isSubset(of: actual))
    }

    @Test("Runtime-audited screens define routes and audit kinds", arguments: AccessibilityContracts.all)
    func runtimeAuditedScreensDefineRoutes(contract: AccessibilityScreenContract) {
        if contract.platform == .iphone || contract.platform == .ipad {
            #expect(contract.runtimeRoute != nil)
            #expect(contract.auditKinds == AccessibilityAuditKind.defaultRuntimeKinds)
        } else {
            #expect(contract.runtimeRoute == nil)
            #expect(contract.auditKinds.isEmpty)
        }
    }
}
