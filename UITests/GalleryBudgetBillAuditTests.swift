/**
 The Atur Budget and Ubah Tagihan pieces in the gallery (UNG-05b, 05c, 05d, 07d), each audited while
 it is up: the failed save keeps the numbers and retries once the dialog is down, the bill
 confirmation cancels without a change, and Pilih Tanggal Gajian applies a day and the month's end.
 The dialogs accept what the gallery's presented-dialog test accepts: the dimmed page behind the
 scrim, which VoiceOver rightly cannot reach while the dialog is modal.
 */
import XCTest

nonisolated final class GalleryBudgetBillAuditTests: XCTestCase {
    @MainActor
    func testBudgetSaveFailureDialogPassesAuditAndKeepsDraftOnRetry() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraGallery", "dialogs"]
        app.launch()

        let scroll = app.scrollViews.firstMatch
        XCTAssertTrue(scroll.waitForExistence(timeout: 10))
        let open = app.buttons["Uji Gagal Menyimpan Budget"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        for _ in 0..<5 where !open.isHittable { scrollDown(scroll) }
        XCTAssertTrue(open.isHittable)

        let amount = app.textFields["Alokasi Budget"]
        XCTAssertTrue(amount.exists)
        let typed = amount.value as? String
        open.tap()

        let title = app.staticTexts["Belum Berhasil Menyimpan"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Koneksi terputus. Angka budgetmu masih ada di layar, coba lagi."].exists)
        XCTAssertTrue(app.buttons["Tutup"].exists)
        try auditInPlace(app) { issue in issue.auditType == .elementDetection && issue.element == nil }
        let retry = hittable(app.buttons, "Coba Lagi")
        XCTAssertTrue(retry.waitForExistence(timeout: 5))
        retry.tap()

        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
        XCTAssertEqual(amount.value as? String, typed)
        XCTAssertTrue(app.staticTexts["Percobaan ulang dipanggil."].waitForExistence(timeout: 5))

        open.tap()
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        let close = hittable(app.buttons, "Tutup")
        XCTAssertTrue(close.waitForExistence(timeout: 5))
        close.tap()
        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
        XCTAssertEqual(amount.value as? String, typed)
        app.terminate()
    }

    @MainActor
    func testBillDeleteDialogPassesAuditAndCancels() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraGallery", "dialogs"]
        app.launch()

        let scroll = app.scrollViews.firstMatch
        XCTAssertTrue(scroll.waitForExistence(timeout: 10))
        let open = app.buttons["Uji Hapus Tagihan"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        for _ in 0..<5 where !open.isHittable { scrollDown(scroll) }
        open.tap()

        let sentence = "Internet Rumah, Rp350.000,00 tiap bulan tidak akan muncul lagi"
        let message = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", sentence)).firstMatch
        XCTAssertTrue(message.waitForExistence(timeout: 5))
        try auditInPlace(app) { issue in issue.auditType == .elementDetection && issue.element == nil }
        let cancel = hittable(app.buttons, "Batal")
        XCTAssertTrue(cancel.waitForExistence(timeout: 5))
        XCTAssertTrue(hittable(app.buttons, "Hapus").exists)
        cancel.tap()
        XCTAssertTrue(message.waitForNonExistence(timeout: 5))
        app.terminate()
    }

    @MainActor
    func testPaydayPickerAppliesTheChosenDayAndTheMonthEnd() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraGallery", "entry"]
        app.launch()

        let scroll = app.scrollViews.firstMatch
        XCTAssertTrue(scroll.waitForExistence(timeout: 10))
        let open = app.buttons["Atur Tanggal Gajian"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        for _ in 0..<5 where !open.isHittable { scrollDown(scroll) }
        open.tap()

        XCTAssertTrue(app.staticTexts["Pilih Tanggal Gajian"].waitForExistence(timeout: 5))
        try auditInPlace(app) { issue in issue.auditType == .elementDetection && issue.element == nil }
        app.buttons["Tanggal 10"].tap()
        app.buttons["Pilih Tanggal 10"].tap()
        XCTAssertTrue(app.staticTexts["Tanggal Gajian: 10"].waitForExistence(timeout: 5))

        open.tap()
        XCTAssertTrue(app.staticTexts["Pilih Tanggal Gajian"].waitForExistence(timeout: 5))
        /** The page's own "Gajian di akhir bulan" checkbox sits behind the sheet: tap the one on top. */
        hittable(app.switches, "Gajian di akhir bulan").tap()
        XCTAssertTrue(app.staticTexts["Kira memakai tanggal terakhir tiap bulan, termasuk Februari."].exists)
        app.buttons["Pilih Akhir Bulan"].tap()
        XCTAssertTrue(app.staticTexts["Gajian di Akhir Bulan"].waitForExistence(timeout: 5))
        app.terminate()
    }

    /** The element labelled `label` that a tap would reach, of those `query` finds (several under a cover). */
    @MainActor
    private func hittable(_ query: XCUIElementQuery, _ label: String) -> XCUIElement {
        let matches = query.matching(NSPredicate(format: "label == %@", label)).allElementsBoundByIndex
        return matches.first { $0.isHittable } ?? query[label]
    }

    /** Scrolls about two thirds of a screen and holds still before lifting, so the page has stopped. */
    @MainActor
    private func scrollDown(_ scroll: XCUIElement) {
        let start = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
        let end = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .default, thenHoldForDuration: 0.5)
    }
}
