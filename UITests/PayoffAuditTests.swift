/**
 Rule 24 for SKR's Rencana Pelunasan: the board as drawn (SKR-03), with "Gimana Ngitungnya?" open
 (SKR-03b) and on Avalanche (SKR-03c). Each opens through `-KiraScreen <name>` and is audited top to
 bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class PayoffAuditTests: XCTestCase {
    @MainActor
    func testPayoffPassesTheAudit() throws {
        try auditScreen("payoff")
    }

    @MainActor
    func testPayoffWithTheFormulaOpenPassesTheAudit() throws {
        try auditScreen("payoffHow")
    }

    @MainActor
    func testPayoffOnAvalanchePassesTheAudit() throws {
        try auditScreen("payoffAvalanche")
    }
}
