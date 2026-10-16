/**
 Rule 24 for BRD and SKR: the three Beranda, Kira Score and the six Detail Indikator.
 Each screen opens through `-KiraScreen <name>` and is audited top to bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class HomeScoreAuditTests: XCTestCase {
    @MainActor
    func testHomePassesTheAudit() throws {
        try auditScreen("home", accepting: { issue in Self.isHeroRibbonHead(issue, "Sudah terpakai") })
    }

    @MainActor
    func testHomeFirstStepsPassesTheAudit() throws {
        try auditScreen("homeFirstSteps")
    }

    @MainActor
    func testHomeDebtPlanPassesTheAudit() throws {
        try auditScreen("homeDebtPlan", accepting: { issue in Self.isHeroRibbonHead(issue, "8% lunas") })
    }

    @MainActor
    func testScorePassesTheAudit() throws {
        try auditScreen(
            "score",
            accepting: { issue in
                /**
                 Accepted: the 11 pt step numbers on their 20 pt badges (board KiraScore: ink on
                 surface-muted, white on pandan). They are drawn only, hidden from VoiceOver, whose card
                 label already holds the step; the audit samples the badge's 2 pt ring and the tile
                 under it as the text's background.
                 */
                guard issue.auditType == .contrast, let label = issue.element?.label else { return false }
                return ["2", "3"].contains(label)
            })
    }

    /**
     Accepted: the head of the bar on the hero card ("Sudah terpakai · 75% dari gaji", "8% lunas ·
     dari …"), whose value is on-hero-muted over the hero's hills, as boards Main and
     BerandaBebasUtang colour it; the owner keeps the board's colours, as for "Lupa PIN?" on the
     lock screen.
     */
    @MainActor
    private static func isHeroRibbonHead(_ issue: XCUIAccessibilityAuditIssue, _ head: String) -> Bool {
        guard issue.auditType == .contrast, let label = issue.element?.label else { return false }
        return label.hasPrefix(head)
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
