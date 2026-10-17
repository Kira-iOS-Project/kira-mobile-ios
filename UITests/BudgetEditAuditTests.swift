/**
 Rule 24 for Atur Budget (UNG-05): the screen on its board's figures, Pilih Tanggal Gajian over it,
 Budget Tersimpan after Simpan Budget, and Belum Berhasil Menyimpan when the save fails.
 */
import XCTest

nonisolated final class BudgetEditAuditTests: XCTestCase {
    @MainActor
    func testBudgetEditPassesTheAudit() throws {
        try auditScreen("budgetEdit")
    }

    @MainActor
    func testPaydayPickerPassesTheAudit() throws {
        try auditScreen("budgetEdit") { app in tap("Tanggal Gajian", in: app) }
    }

    @MainActor
    func testSavedPassesTheAudit() throws {
        try auditScreen("budgetEdit") { app in
            save(in: app)
            XCTAssertTrue(app.buttons["Selesai"].waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testSaveFailedPassesTheAudit() throws {
        try auditScreen("budgetEditFailing") { app in
            save(in: app)
            XCTAssertTrue(app.buttons["Coba Lagi"].waitForExistence(timeout: 5))
        }
    }

    /** Scrolls to Simpan Budget and taps it. */
    @MainActor
    private func save(in app: XCUIApplication) {
        let button = app.buttons["Simpan Budget"].firstMatch
        for _ in 0..<6 where !button.isHittable { app.swipeUp() }
        tap("Simpan Budget", in: app)
    }

    @MainActor
    private func tap(_ label: String, in app: XCUIApplication) {
        let button = app.buttons[label].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 5), "no \(label)")
        button.tap()
    }
}
