/**
 Apple's accessibility audit on every primary screen (AGENTS.md Rule 24). The project's default
 isolation is the main actor and XCTestCase is not, so the class opts out and each test opts back in.
 */
import XCTest

nonisolated final class AccessibilityAuditTests: XCTestCase {
    @MainActor
    func testRootScreenPassesTheAudit() throws {
        let app = XCUIApplication()
        app.launch()
        try app.performAccessibilityAudit()
    }
}
