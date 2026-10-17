/**
 Rule 24 for Riwayat Kira Score (SKR-07): the board's six months, the year (SKR-07b, after a tap on
 1 Tahun), a single month of data, the empty state before the health check, and a failed load. Each
 opens through `-KiraScreen <name>` (ScreenAudit.swift).
 */
import XCTest

nonisolated final class ScoreHistoryAuditTests: XCTestCase {
    @MainActor
    func testSixMonthsPassTheAudit() throws {
        try auditScreen("scoreHistory")
    }

    /** RiwayatSkorTahun: 1 Tahun in the Rentang waktu control. */
    @MainActor
    func testOneYearPassesTheAudit() throws {
        try auditScreen("scoreHistory") { app in
            let year = app.buttons["1 Tahun"]
            XCTAssertTrue(year.waitForExistence(timeout: 10))
            year.tap()
        }
    }

    @MainActor
    func testOneMonthPassesTheAudit() throws {
        try auditScreen("scoreHistoryShort")
    }

    @MainActor
    func testBeforeTheHealthCheckPassesTheAudit() throws {
        try auditScreen("scoreHistoryEmpty")
    }

    @MainActor
    func testFailedLoadPassesTheAudit() throws {
        try auditScreen("scoreHistoryFailed") { app in
            XCTAssertTrue(app.buttons["Coba Lagi"].waitForExistence(timeout: 10))
        }
    }
}
