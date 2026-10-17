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
        try auditScreen("goalRetirementResult", accepting: Self.isCompositionLegend)
    }

    /**
     Accepted: "Contrast failed" on Komposisi hasil investasi's two legend labels ("Pokok · N%",
     "Imbal Hasil · N%"), the design system's muted 13 pt caption on the card, which the other goal
     results pass with; nothing else.
     */
    @MainActor
    private static func isCompositionLegend(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        guard issue.auditType == .contrast, let label = issue.element?.label else { return false }
        return label.hasPrefix("Pokok · ") || label.hasPrefix("Imbal Hasil · ")
    }
}
