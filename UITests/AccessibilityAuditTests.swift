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
        XCTAssertTrue(app.staticTexts.firstMatch.waitForExistence(timeout: 10))
        try auditInPlace(app)
    }

    /** AKN-02 Kira Terkunci, through the debug-only `-KiraLocked` on the preview services (no live API). */
    @MainActor
    func testLockScreenPassesTheAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraLocked", "-KiraPreviewServices"]
        app.launch()
        XCTAssertTrue(app.buttons["Lupa PIN?"].waitForExistence(timeout: 10))
        try auditInPlace(app) { issue in
            /**
             Accepted: "Lupa PIN?" and the 0 key, the two that sit over the hero hills, in the
             board's colours (BukaKunci.dc.html: on-hero-muted, and on-hero on hero-track); the owner
             keeps the design. Every other finding fails.
             */
            guard issue.auditType == .contrast, let label = issue.element?.label else { return false }
            return label == "Lupa PIN?" || label == "0"
        }
    }

    /** AKN-02b Lupa PIN: "Lupa PIN?" on the lock screen opens the emailed code step. */
    @MainActor
    func testPinRecoveryPassesTheAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraLocked", "-KiraPreviewServices"]
        app.launch()
        let forgot = app.buttons["Lupa PIN?"]
        XCTAssertTrue(forgot.waitForExistence(timeout: 10))
        forgot.tap()
        XCTAssertTrue(app.staticTexts["Kode Verifikasi"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 1.5)
        try auditInPlace(app)
    }
}
