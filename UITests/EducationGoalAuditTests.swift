/**
 Rule 24 for Pendidikan Anak: Tujuan Baru (REN-02c), Atur Jenjang (REN-02i) and Hasil Simulasi
 (REN-04d), on the board's Raka. Each screen opens through `-KiraScreen <name>` and is audited top to
 bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class EducationGoalAuditTests: XCTestCase {
    @MainActor
    func testEducationGoalPassesTheAudit() throws {
        try auditScreen("educationGoal")
    }

    @MainActor
    func testEducationGoalStagePassesTheAudit() throws {
        try auditScreen("educationGoalStage")
    }

    @MainActor
    func testEducationGoalResultPassesTheAudit() throws {
        try auditScreen("educationGoalResult")
    }
}
