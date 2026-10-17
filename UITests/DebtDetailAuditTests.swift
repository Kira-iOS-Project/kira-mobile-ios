/**
 Rule 24 for UNG-03 Detail Utang (Paylater A, and a debt that is gone, with Coba Lagi) and SKR-06
 Panduan SLIK. Each opens through `-KiraScreen <name>` (ScreenAudit.swift).
 */
import XCTest

nonisolated final class DebtDetailAuditTests: XCTestCase {
    @MainActor
    func testDebtDetailPassesTheAudit() throws {
        try auditScreen("debtDetail") { app in
            XCTAssertTrue(app.buttons["Lihat Rencana Pelunasan"].waitForExistence(timeout: 10))
        }
    }

    @MainActor
    func testGoneDebtPassesTheAudit() throws {
        try auditScreen("debtDetailGone") { app in
            XCTAssertTrue(app.buttons["Coba Lagi"].waitForExistence(timeout: 10))
        }
    }

    @MainActor
    func testCreditReportGuidePassesTheAudit() throws {
        try auditScreen("creditReportGuide") { app in
            XCTAssertTrue(app.buttons["Buka iDebKu OJK"].waitForExistence(timeout: 10))
        }
    }
}
