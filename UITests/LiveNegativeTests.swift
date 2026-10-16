/**
 The live negative cases against a real local backend, on the account LiveFlowTests created: a
 wrong sign-in code then the right one (the data still there after signing out), the Catat AI quota
 sheet once the month's messages are spent, and a save while the server is down. The driver script
 sets the backend up for each: it spends the quota through the API before test07 and stops the
 server before test08 (`KIRA_LIVE_SERVER_DOWN`). Skipped unless KIRA_LIVE_SERVER is set.
 */
import XCTest

nonisolated final class LiveNegativeTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func test06SignOutWrongCodeThenSignInAgain() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        LiveFlow.unlock(app)
        tap(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Profil'")).firstMatch, app, timeout: 20)
        let signOut = app.buttons["Keluar"]
        for _ in 0..<4 where !signOut.isHittable { app.swipeUp() }
        tap(signOut, app)
        LiveFlow.expect(app.staticTexts["Keluar dari Kira?"], in: self, app: app)
        tap(LiveFlow.dialogButton("Keluar", in: app), app)
        LiveFlow.shot("neg-00-signed-out", in: self)
        if app.buttons["Lewati"].waitForExistence(timeout: 15) { app.buttons["Lewati"].tap() }
        tap(app.buttons["Aku Sudah Punya Akun"], app)
        let sent = try LiveFlow.codes(for: LiveFlow.email).count
        LiveFlow.type(LiveFlow.email, into: app.textFields["Email"], in: self, app: app)
        tap(app.buttons["Kirim Kode Masuk"], app)
        let field = app.textFields["Kode Verifikasi 6 Digit"]
        LiveFlow.type("000000", into: field, in: self, app: app)
        LiveFlow.expect(app.staticTexts["Kodenya belum cocok. Periksa lagi emailmu, ya."], in: self, app: app)
        LiveFlow.shot("neg-01-wrong-code", in: self)
        let code = try LiveFlow.waitForCode(after: sent)
        LiveFlow.type(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 6) + code, into: field, in: self, app: app)
        LiveFlow.shot("neg-02-signed-in", in: self)
        tap(app.buttons["Catat"], app, timeout: 30)
        tap(app.buttons["Riwayat transaksi"], app)
        LiveFlow.expect(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Parkir'")).firstMatch, in: self, app: app)
        LiveFlow.shot("neg-03-data-kept", in: self)
    }

    @MainActor
    func test07ChatQuotaSpent() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        LiveFlow.unlock(app)
        tap(app.buttons["Catat"], app, timeout: 20)
        LiveFlow.type("bensin 20rb", into: app.textFields["Tulis Pengeluaran atau Pemasukan"], in: self, app: app)
        tap(app.buttons["Kirim"], app)
        LiveFlow.expect(app.staticTexts["Kuota Chat AI Bulan Ini Habis"], in: self, timeout: 20, app: app)
        LiveFlow.shot("neg-04-quota", in: self)
        tap(app.buttons["Catat Manual"], app)
        LiveFlow.expect(app.textFields["Jumlah"], in: self, app: app)
        LiveFlow.shot("neg-05-quota-manual", in: self)
    }

    @MainActor
    func test08SaveWhileTheServerIsDown() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        try XCTSkipUnless(ProcessInfo.processInfo.environment["KIRA_LIVE_SERVER_DOWN"] != nil, "the server is up")
        LiveFlow.unlock(app)
        tap(app.buttons["Catat"], app, timeout: 20)
        tap(app.buttons["Catat manual, isi formulir"], app)
        LiveFlow.type("9000", into: app.textFields["Jumlah"], in: self, app: app)
        LiveFlow.type("Tol", into: app.textFields["Nama"], in: self, app: app)
        tap(app.buttons["Simpan Transaksi"], app)
        LiveFlow.expect(app.staticTexts["Koneksi terputus. Coba lagi sebentar lagi, ya."], in: self, timeout: 30, app: app)
        LiveFlow.shot("neg-06-server-down", in: self)
        tap(app.buttons["Tutup"], app)
        LiveFlow.expect(app.textFields["Nama"], in: self, app: app)
        XCTAssertEqual(app.textFields["Nama"].value as? String, "Tol", "the form keeps what was typed")
        LiveFlow.shot("neg-07-input-kept", in: self)
    }

    @MainActor
    private func tap(_ element: XCUIElement, _ app: XCUIApplication, timeout: TimeInterval = 10) {
        LiveFlow.tap(element, in: self, timeout: timeout, app: app)
    }
}
