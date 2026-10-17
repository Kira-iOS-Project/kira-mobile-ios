/**
 Rule 24 for Rencana Keselamatanku (PED-10) saved and never saved, its form (PED-10c), Rencana
 Tersimpan (PED-10b) after Simpan Rencana, the failure dialog of a save the API refuses, and Latihan
 Menenangkan Diri (PED-11). Each opens through `-KiraScreen <name>` and a tap (ScreenAudit.swift).
 */
import XCTest

nonisolated final class CareSafetyAuditTests: XCTestCase {
    @MainActor
    func testSafetyPlanPassesTheAudit() throws {
        try auditScreen("safetyPlan")
    }

    @MainActor
    func testEmptySafetyPlanPassesTheAudit() throws {
        try auditScreen("safetyPlanEmpty")
    }

    @MainActor
    func testSafetyPlanFormPassesTheAudit() throws {
        try auditScreen("safetyPlanForm", accepting: Self.contactHeaderContrast)
    }

    /** RencanaKeselamatanDialogBerhasil: Simpan Rencana under the plan. */
    @MainActor
    func testSavedDialogPassesTheAudit() throws {
        try auditScreen(
            "safetyPlan",
            prepare: { app in
                Self.tap(app.buttons["Simpan Rencana"])
                XCTAssertTrue(app.staticTexts["Rencana Tersimpan"].waitForExistence(timeout: 5))
            },
            accepting: Self.behindDialog)
    }

    /** A save the API refuses: the failure dialog with Coba Lagi and Tutup. */
    @MainActor
    func testFailedSaveDialogPassesTheAudit() throws {
        try auditScreen(
            "safetyPlanFailing",
            prepare: { app in
                Self.tap(app.buttons["Simpan Rencana"])
                XCTAssertTrue(app.staticTexts["Rencana Belum Tersimpan"].waitForExistence(timeout: 5))
                XCTAssertTrue(app.buttons["Coba Lagi"].exists && app.buttons["Tutup"].exists)
            },
            accepting: Self.behindDialog)
    }

    @MainActor
    func testBreathingPassesTheAudit() throws {
        try auditScreen("breathing")
    }

    /**
     Accepted, the owner's call: contrast on Isi Rencana Keselamatanku's contact part title "Orang
     yang Bisa Kuhubungi" and its Tambah Kontak button, and nothing else. Both are ink on the
     surface, their element screenshots show clean ink on cream, their styles pass everywhere else,
     and CI before the audit's scroll changed (fece597) never flagged them; the audit reads them as
     low contrast at fixed frames, the title before any scroll, for a cause not yet found.
     */
    @MainActor
    private static func contactHeaderContrast(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        guard issue.auditType == .contrast, let label = issue.element?.label else { return false }
        return ["Orang yang Bisa Kuhubungi", "Tambah Kontak"].contains(label)
    }

    /** Accepted, as for every presented dialog (docs/design-system.md): text behind its scrim. */
    private static func behindDialog(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        issue.auditType == .elementDetection && issue.element == nil
    }

    @MainActor
    private static func tap(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        element.tap()
    }
}
