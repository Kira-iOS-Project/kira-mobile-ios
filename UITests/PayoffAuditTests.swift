/**
 Rule 24 for SKR's Rencana Pelunasan: the board as drawn (SKR-03), with "Gimana Ngitungnya?" open
 (SKR-03b) and on Avalanche (SKR-03c). Each opens through `-KiraScreen <name>` and is audited top to
 bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class PayoffAuditTests: XCTestCase {
    @MainActor
    func testPayoffPassesTheAudit() throws {
        try auditScreen("payoff", accepting: Self.heroLastLine)
    }

    @MainActor
    func testPayoffWithTheFormulaOpenPassesTheAudit() throws {
        try auditScreen("payoffHow", accepting: Self.heroLastLine)
    }

    @MainActor
    func testPayoffOnAvalanchePassesTheAudit() throws {
        try auditScreen("payoffAvalanche", accepting: Self.heroLastLine)
    }

    /**
     Accepted, the owner's decision (as for Langganan's hero and Kira Score's date): "Contrast failed"
     on the hero's last line, "Semua utang konsumtif lunas …" (or "Dengan angka ini, belum semua …"),
     which the RencanaPelunasan boards draw over the hero's hills with 22 pt below it. The white text
     on the hero colour itself passes; only the hills behind it lower the measure. Every other
     finding fails.
     */
    private static func heroLastLine(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        guard issue.auditType == .contrast, let label = issue.element?.label else { return false }
        return label.hasPrefix("Semua utang konsumtif lunas") || label.hasPrefix("Dengan angka ini")
    }
}
