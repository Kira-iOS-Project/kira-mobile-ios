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

    /** AKN-02 Kira Terkunci, reached through the debug-only `-KiraLocked` launch argument. */
    @MainActor
    func testLockScreenPassesTheAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraLocked"]
        app.launch()
        XCTAssertTrue(app.buttons["Lupa PIN?"].waitForExistence(timeout: 5))
        try app.performAccessibilityAudit { issue in
            /**
             Accepted: "Lupa PIN?" is on-hero-muted over the hero hills, the board's colours
             (BukaKunci.dc.html); the owner keeps the design. Every other finding fails.
             */
            issue.auditType == .contrast && issue.element?.label == "Lupa PIN?"
        }
    }

    /** AKN-02b Lupa PIN: "Lupa PIN?" on the lock screen opens the emailed code step. */
    @MainActor
    func testPinRecoveryPassesTheAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraLocked"]
        app.launch()
        let forgot = app.buttons["Lupa PIN?"]
        XCTAssertTrue(forgot.waitForExistence(timeout: 5))
        forgot.tap()
        XCTAssertTrue(app.staticTexts["Kode Verifikasi"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 1.5)
        try app.performAccessibilityAudit()
    }
}
