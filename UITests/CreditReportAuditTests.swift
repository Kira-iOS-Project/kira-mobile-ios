/**
 Rule 24 for Cek SLIK (SKR-06): the four steps, the privacy promise, the warning about paid check
 services and Buka iDebKu OJK, top to bottom. It opens through `-KiraScreen creditReport`
 (ScreenAudit.swift).
 */
import XCTest

nonisolated final class CreditReportAuditTests: XCTestCase {
    @MainActor
    func testCreditReportPassesTheAudit() throws {
        try auditScreen("creditReport") { app in
            XCTAssertTrue(app.buttons["Buka iDebKu OJK"].waitForExistence(timeout: 10))
        }
    }
}
