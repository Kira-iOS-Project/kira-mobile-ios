/**
 Rule 24 for ONB: the splash, the intro, Buat Akun and Masuk, the code, the setup, the six
 health-check steps, the result and Kunci Kira.
 Each screen opens through `-KiraScreen <name>` and is audited top to bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class OnboardingAuditTests: XCTestCase {
    @MainActor
    func testSplashPassesTheAudit() throws {
        try auditScreen("splash")
    }

    @MainActor
    func testIntroPassesTheAudit() throws {
        try auditScreen("intro")
    }

    @MainActor
    func testSignUpPassesTheAudit() throws {
        try auditScreen("signUp")
    }

    @MainActor
    func testSignInPassesTheAudit() throws {
        try auditScreen("signIn")
    }

    @MainActor
    func testCodePassesTheAudit() throws {
        try auditScreen("code")
    }

    @MainActor
    func testConsentPassesTheAudit() throws {
        try auditScreen("consent")
    }

    @MainActor
    func testFocusPassesTheAudit() throws {
        try auditScreen("focus")
    }

    @MainActor
    func testIncomePassesTheAudit() throws {
        try auditScreen("income")
    }

    @MainActor
    func testExpensesPassesTheAudit() throws {
        try auditScreen("expenses")
    }

    @MainActor
    func testDebtsPassesTheAudit() throws {
        try auditScreen("debts")
    }

    /** Tambah Rincian Utang, from Tambah Utang Lain: its panel starts low, the Utang step above it. */
    @MainActor
    func testDebtSheetPassesTheAudit() throws {
        try auditScreen(
            "debts",
            prepare: { app in
                let add = app.buttons["Tambah Utang Lain"]
                XCTAssertTrue(add.waitForExistence(timeout: 10))
                add.tap()
                XCTAssertTrue(app.staticTexts["Tambah Rincian Utang"].waitForExistence(timeout: 5))
            },
            accepting: { issue in
                /** Accepted, as for the drafts sheet (ChatAuditTests): text behind the sheet's scrim. */
                issue.auditType == .elementDetection && issue.element == nil
            })
    }

    @MainActor
    func testSavingsPassesTheAudit() throws {
        try auditScreen("savings")
    }

    @MainActor
    func testAssetsPassesTheAudit() throws {
        try auditScreen("assets")
    }

    @MainActor
    func testProtectionPassesTheAudit() throws {
        try auditScreen("protection")
    }

    @MainActor
    func testResultPassesTheAudit() throws {
        try auditScreen("result")
    }

    @MainActor
    func testPinPassesTheAudit() throws {
        try auditScreen("pin")
    }
}
