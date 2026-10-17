/**
 Rule 24 for Ringkasan Mingguan (UNG-08): the board's week, a week without spending and a week that
 failed to load, each through `-KiraScreen <name>` and audited top to bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class WeeklySummaryAuditTests: XCTestCase {
    @MainActor
    func testWeeklySummaryPassesTheAudit() throws {
        try auditScreen("weeklySummary")
    }

    @MainActor
    func testEmptyWeekPassesTheAudit() throws {
        try auditScreen("weeklySummaryEmpty")
    }

    @MainActor
    func testFailedWeekPassesTheAudit() throws {
        try auditScreen("weeklySummaryFailed") { app in
            XCTAssertTrue(app.buttons["Coba Lagi"].waitForExistence(timeout: 5), "no Coba Lagi")
        }
    }
}
