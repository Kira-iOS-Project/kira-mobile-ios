/**
 Rule 24 for REN-08 Modul Belajar: the module of each asset class (Reksa Dana Pasar Uang, SBN,
 Deposito, Emas, Saham, Kripto) opens through `-KiraScreen <name>` and is audited top to bottom
 (ScreenAudit.swift).
 */
import XCTest

nonisolated final class AssetModuleAuditTests: XCTestCase {
    @MainActor
    func testMoneyMarketFundModulePassesTheAudit() throws {
        try auditScreen("moduleMoneyMarketFund")
    }

    @MainActor
    func testGovernmentBondsModulePassesTheAudit() throws {
        try auditScreen("moduleGovernmentBonds", accepting: Self.scrolledPassContrast)
    }

    @MainActor
    func testDepositsModulePassesTheAudit() throws {
        try auditScreen("moduleDeposits", accepting: Self.scrolledPassContrast)
    }

    @MainActor
    func testGoldModulePassesTheAudit() throws {
        try auditScreen("moduleGold", accepting: Self.scrolledPassContrast)
    }

    @MainActor
    func testStocksModulePassesTheAudit() throws {
        try auditScreen("moduleStocks", accepting: Self.scrolledPassContrast)
    }

    @MainActor
    func testCryptoModulePassesTheAudit() throws {
        try auditScreen("moduleCrypto", accepting: Self.scrolledPassContrast)
    }

    /**
     Accepted by the owner (2026-10-17): contrast on three elements of the module, and nothing else: the section title
     "Cocok untuk", the "Cek Legalitas" link and the education notice's sentence. The audit flags them only on the
     passes after a scroll (the acceptance cannot tell the passes apart). All three are in the board's colours
     (ink, pandan and ink-muted on surface-raised), pass on the first, unscrolled pass of every module, and pass on
     every pass of Reksa Dana Pasar Uang, whose layout is the same. On passes 2 and 3 the audit reports them at the
     same frame although the content has scrolled between the passes: the end-of-scroll bounce that ScreenAudit
     describes, which samples pixels that have moved under a stale frame.
     */
    @MainActor
    private static func scrolledPassContrast(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        guard issue.auditType == .contrast, let label = issue.element?.label else { return false }
        return ["Cocok untuk", "Cek Legalitas", "Modul ini tidak menyebut produk atau pengelola tertentu."]
            .contains(label)
    }
}
