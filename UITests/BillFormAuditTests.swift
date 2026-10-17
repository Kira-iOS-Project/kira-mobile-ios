/**
 Rule 24 for UNG's bill forms: Tambah Tagihan (UNG-07), Tagihan Tersimpan (UNG-07b), Belum Berhasil
 Menyimpan, Ubah Tagihan (UNG-07c) and Hapus Tagihan Ini? (UNG-07d). Each screen opens through
 `-KiraScreen <name>` and is audited top to bottom (ScreenAudit.swift); a dialog is opened first.
 */
import XCTest

nonisolated final class BillFormAuditTests: XCTestCase {
    @MainActor
    func testAddBillPassesTheAudit() throws {
        try auditScreen("billAdd")
    }

    @MainActor
    func testBillSavedPassesTheAudit() throws {
        try auditScreen("billAddSaved") { app in Self.open(app, button: "Simpan Tagihan", until: "Tagihan Tersimpan") }
    }

    @MainActor
    func testBillSaveFailurePassesTheAudit() throws {
        try auditScreen("billAddFailing") { app in
            Self.open(app, button: "Simpan Tagihan", until: "Belum Berhasil Menyimpan")
        }
    }

    @MainActor
    func testEditBillPassesTheAudit() throws {
        try auditScreen("billEdit")
    }

    @MainActor
    func testDeleteBillDialogPassesTheAudit() throws {
        try auditScreen("billEdit") { app in Self.open(app, button: "Hapus Tagihan", until: "Hapus Tagihan Ini?") }
    }

    /** Taps `button` and waits for the dialog titled `title`. */
    @MainActor
    private static func open(_ app: XCUIApplication, button: String, until title: String) {
        app.buttons[button].firstMatch.tap()
        XCTAssertTrue(app.staticTexts[title].firstMatch.waitForExistence(timeout: 5))
    }
}
