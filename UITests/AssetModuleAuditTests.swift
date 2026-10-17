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
        try auditScreen("moduleGovernmentBonds")
    }

    @MainActor
    func testDepositsModulePassesTheAudit() throws {
        try auditScreen("moduleDeposits")
    }

    @MainActor
    func testGoldModulePassesTheAudit() throws {
        try auditScreen("moduleGold")
    }

    @MainActor
    func testStocksModulePassesTheAudit() throws {
        try auditScreen("moduleStocks")
    }

    @MainActor
    func testCryptoModulePassesTheAudit() throws {
        try auditScreen("moduleCrypto")
    }
}
