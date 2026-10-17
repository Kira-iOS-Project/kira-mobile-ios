/**
 Rule 24 for Portofolio Manual (REN-10) shown, masked, empty and failed; Tambah Aset (REN-11) and
 its update form; Aset Tersimpan (REN-11b) after Simpan Aset; and the failure dialog of a save
 that never went through. Each opens through `-KiraScreen <name>` and a tap (ScreenAudit.swift).
 */
import XCTest

nonisolated final class PortfolioAuditTests: XCTestCase {
    @MainActor
    func testPortfolioPassesTheAudit() throws {
        try auditScreen("portfolio")
    }

    @MainActor
    func testMaskedPortfolioPassesTheAudit() throws {
        try auditScreen("portfolioMasked") { app in
            XCTAssertTrue(app.buttons["Tampilkan nilai aset"].waitForExistence(timeout: 10))
        }
    }

    @MainActor
    func testEmptyPortfolioPassesTheAudit() throws {
        try auditScreen("portfolioEmpty")
    }

    @MainActor
    func testFailedPortfolioPassesTheAudit() throws {
        try auditScreen("portfolioFailed") { app in
            XCTAssertTrue(app.buttons["Coba Lagi"].waitForExistence(timeout: 10))
        }
    }

    @MainActor
    func testAddAssetPassesTheAudit() throws {
        try auditScreen("addAsset")
    }

    @MainActor
    func testEditAssetPassesTheAudit() throws {
        try auditScreen("editAsset") { app in
            XCTAssertTrue(app.buttons["Simpan Perubahan"].waitForExistence(timeout: 10))
        }
    }

    /** TambahAsetDialogBerhasil: the board's gold, saved. */
    @MainActor
    func testSavedDialogPassesTheAudit() throws {
        try auditScreen(
            "addAsset", prepare: { app in Self.fillAndSave(app, expecting: "Aset Tersimpan") },
            accepting: Self.behindDialog)
    }

    /** A save that never got an answer: Belum Berhasil Menyimpan, with Coba Lagi and Tutup. */
    @MainActor
    func testFailedSaveDialogPassesTheAudit() throws {
        try auditScreen(
            "addAssetFailing",
            prepare: { app in
                Self.fillAndSave(app, expecting: "Belum Berhasil Menyimpan")
                XCTAssertTrue(app.buttons["Coba Lagi"].exists && app.buttons["Tutup"].exists)
            },
            accepting: Self.behindDialog)
    }

    /** Emas, "Emas Batangan" and 2.400.000, as on the board, then Simpan Aset. */
    @MainActor
    private static func fillAndSave(_ app: XCUIApplication, expecting title: String) {
        tap(app.buttons["Emas"])
        type("Emas Batangan", into: app.textFields["Nama"])
        type("2400000", into: app.textFields["Nilai Sekarang"])
        tap(app.buttons["Simpan Aset"])
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 10))
    }

    @MainActor
    private static func type(_ text: String, into field: XCUIElement) {
        tap(field)
        field.typeText(text)
    }

    @MainActor
    private static func tap(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        element.tap()
    }

    /** Accepted, as for every presented dialog (docs/design-system.md): text behind its scrim. */
    private static func behindDialog(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        issue.auditType == .elementDetection && issue.element == nil
    }
}
