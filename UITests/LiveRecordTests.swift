/**
 The live walk of CAT against a real local backend, on the account LiveFlowTests created: a chat
 message read into drafts and saved, Riwayat, a transaction changed and deleted, and Catat Manual.
 Skipped unless KIRA_LIVE_SERVER is set.
 */
import XCTest

nonisolated final class LiveRecordTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func test03ChatDraftsSavedToRiwayat() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        LiveFlow.unlock(app)
        tap(app.buttons["Catat"], app, timeout: 20)
        LiveFlow.type(
            "makan siang 25rb, kopi goceng", into: app.textFields["Tulis Pengeluaran atau Pemasukan"], in: self,
            app: app)
        tap(app.buttons["Kirim"], app)
        let save = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Simpan'")).firstMatch
        LiveFlow.expect(save, in: self, timeout: 20, app: app)
        LiveFlow.shot("cat-01-drafts", in: self)
        save.tap()
        LiveFlow.expect(
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Tersimpan'")).firstMatch, in: self, app: app)
        LiveFlow.shot("cat-02-saved", in: self)
        tap(app.buttons["Riwayat transaksi"], app)
        LiveFlow.expect(app.staticTexts["Riwayat Transaksi"], in: self, app: app)
        LiveFlow.shot("cat-03-history", in: self)
    }

    @MainActor
    func test04TransactionChangedThenDeleted() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        LiveFlow.unlock(app)
        tap(app.buttons["Catat"], app, timeout: 20)
        tap(app.buttons["Riwayat transaksi"], app)
        tap(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Makan Siang'")).firstMatch, app)
        LiveFlow.expect(app.staticTexts["Detail Transaksi"], in: self, app: app)
        LiveFlow.shot("cat-04-detail", in: self)
        tap(app.buttons["Ubah"], app)
        let amount = app.textFields["Jumlah"]
        /** A new amount every run: an unchanged form closes without "Perubahan Tersimpan". */
        let changed = (amount.value as? String ?? "").hasPrefix("27") ? "28000" : "27000"
        LiveFlow.type(
            String(repeating: XCUIKeyboardKey.delete.rawValue, count: 12) + changed, into: amount, in: self, app: app)
        tap(app.buttons["Simpan"], app)
        LiveFlow.expect(app.staticTexts["Perubahan Tersimpan"], in: self, app: app)
        LiveFlow.shot("cat-05-changed", in: self)
        tap(app.buttons["Selesai"], app)
        tap(app.buttons["Hapus"], app)
        LiveFlow.expect(app.staticTexts["Hapus Transaksi Ini?"], in: self, app: app)
        tap(LiveFlow.dialogButton("Hapus", in: app), app)
        LiveFlow.expect(app.staticTexts["Transaksi Dihapus"], in: self, app: app)
        LiveFlow.shot("cat-06-deleted", in: self)
        tap(app.buttons["Kembali ke Riwayat"], app)
    }

    @MainActor
    func test05ManualEntry() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        LiveFlow.unlock(app)
        tap(app.buttons["Catat"], app, timeout: 20)
        tap(app.buttons["Catat manual, isi formulir"], app)
        LiveFlow.type("15000", into: app.textFields["Jumlah"], in: self, app: app)
        LiveFlow.type("Parkir", into: app.textFields["Nama"], in: self, app: app)
        LiveFlow.shot("cat-07-manual", in: self)
        tap(app.buttons["Simpan Transaksi"], app)
        LiveFlow.expect(app.staticTexts["Transaksi Tersimpan"], in: self, app: app)
        LiveFlow.shot("cat-08-manual-saved", in: self)
    }

    @MainActor
    private func tap(_ element: XCUIElement, _ app: XCUIApplication, timeout: TimeInterval = 10) {
        LiveFlow.tap(element, in: self, timeout: timeout, app: app)
    }
}
