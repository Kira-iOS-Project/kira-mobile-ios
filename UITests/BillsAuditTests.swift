/**
 Rule 24 for Tagihan & Cicilan (UNG-06): the board's bills, none, and a load that fails. Each opens
 through `-KiraScreen <name>` and is audited top to bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class BillsAuditTests: XCTestCase {
    @MainActor
    func testBillsPassesTheAudit() throws {
        try auditScreen("bills")
    }

    @MainActor
    func testBillsEmptyPassesTheAudit() throws {
        try auditScreen("billsEmpty")
    }

    @MainActor
    func testBillsFailedPassesTheAudit() throws {
        try auditScreen("billsFailed")
    }
}
