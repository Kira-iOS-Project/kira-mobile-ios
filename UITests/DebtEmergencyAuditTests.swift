/**
 Rule 24 for PED's debt screens: Mode Darurat Utang (PED-07) and its guides Ditagih Kasar (PED-08),
 Diteror Pinjol Ilegal (PED-13), Aduan Belum Selesai (PED-14) and Ditawari Jasa "Pelunasan"
 (PED-15). Each screen opens through `-KiraScreen <name>` and is audited top to bottom
 (ScreenAudit.swift).
 */
import XCTest

nonisolated final class DebtEmergencyAuditTests: XCTestCase {
    @MainActor
    func testDebtEmergencyPassesTheAudit() throws {
        try auditScreen("debtEmergency")
    }

    @MainActor
    func testHarshCollectionPassesTheAudit() throws {
        try auditScreen("harshCollection")
    }

    @MainActor
    func testIllegalLenderPassesTheAudit() throws {
        try auditScreen("illegalLender")
    }

    @MainActor
    func testUnresolvedComplaintPassesTheAudit() throws {
        try auditScreen("unresolvedComplaint")
    }

    @MainActor
    func testPayoffOfferPassesTheAudit() throws {
        try auditScreen("payoffOffer")
    }
}
