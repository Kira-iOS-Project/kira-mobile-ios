/**
 Rule 24 for ONB: the splash, the intro, Buat Akun and Masuk, the code, the setup, the six health-check steps, the result and Kunci Kira.
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
