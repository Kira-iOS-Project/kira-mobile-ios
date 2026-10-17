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

    /** Pilih Tanggal Gajian (ONB-10b) over the income step: the shared payday sheet Atur Budget uses too. */
    @MainActor
    func testPaydaySheetPassesTheAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "income"]
        app.launch()
        let field = app.buttons["Tanggal Gajian"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()
        XCTAssertTrue(app.staticTexts["Pilih Tanggal Gajian"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Pilih Tanggal 25"].exists)
        Thread.sleep(forTimeInterval: 1)
        try auditInPlace(app) { issue in issue.auditType == .elementDetection && issue.element == nil }
        app.terminate()
    }

    @MainActor
    func testExpensesPassesTheAudit() throws {
        try auditScreen("expenses")
    }

    @MainActor
    func testDebtsPassesTheAudit() throws {
        try auditScreen("debts")
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
