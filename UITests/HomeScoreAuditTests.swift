/**
 Rule 24 for BRD and SKR: the three Beranda, Kira Score and the six Detail Indikator.
 Each screen opens through `-KiraScreen <name>` and is audited top to bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class HomeScoreAuditTests: XCTestCase {
    @MainActor
    func testHomePassesTheAudit() throws {
        try auditScreen("home")
    }

    @MainActor
    func testHomeFirstStepsPassesTheAudit() throws {
        try auditScreen("homeFirstSteps")
    }

    @MainActor
    func testHomeDebtPlanPassesTheAudit() throws {
        try auditScreen("homeDebtPlan")
    }

    @MainActor
    func testScorePassesTheAudit() throws {
        try auditScreen("score")
    }

    @MainActor
    func testEmergencyFundPassesTheAudit() throws {
        try auditScreen("emergencyFund")
    }

    @MainActor
    func testSavingsRatioPassesTheAudit() throws {
        try auditScreen("savingsRatio")
    }

    @MainActor
    func testInstalmentRatioPassesTheAudit() throws {
        try auditScreen("instalmentRatio")
    }

    @MainActor
    func testConsumerDebtPassesTheAudit() throws {
        try auditScreen("consumerDebt")
    }

    @MainActor
    func testDebtToAssetPassesTheAudit() throws {
        try auditScreen("debtToAsset")
    }

    @MainActor
    func testProtectionCoverPassesTheAudit() throws {
        try auditScreen("protectionCover")
    }
}
