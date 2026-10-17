/**
 Rule 24 for REN's Dana Pensiun: Tujuan Baru · Dana Pensiun (REN-02e) and its Hasil Simulasi
 (REN-04f). Each screen opens through `-KiraScreen <name>` and is audited top to bottom
 (ScreenAudit.swift).
 */
import XCTest

nonisolated final class RetirementGoalAuditTests: XCTestCase {
    @MainActor
    func testGoalRetirementPassesTheAudit() throws {
        try auditScreen("goalRetirement")
    }

    @MainActor
    func testGoalRetirementResultPassesTheAudit() throws {
        try auditScreen("goalRetirementResult")
    }
}
