/**
 The live walk of flows 7 (Komunitas) and 8 (Kira Peduli) against a real local backend
 (LiveFlow.swift says how to run it), on one new account whose health check records a Paylater
 debt for Naskah Keringanan. This file: sign-up, Komunitas, Detail Grup with Gabung (the rules, then
 COMMUNITY_LINK_UNAVAILABLE, since no group link is set) and Laporkan Grup (Lainnya without a story
 blocked inline, a report sent, a second one refused), Etalase, a product and Kirim Produk.
 LiveCommunityCareTests+Care.swift walks Kira Peduli. Skipped unless KIRA_LIVE_SERVER is set.
 */
import XCTest

nonisolated final class LiveCommunityCareTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func test10SignUpWithADebt() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        tap(app.buttons["Lewati"], app)
        tap(app.buttons["Daftar dengan Email"], app)
        let sent = try LiveFlow.codes(for: LiveFlow.email).count
        LiveFlow.type(LiveFlow.email, into: app.textFields["Email"], in: self, app: app)
        tap(app.buttons["Kirim Kode"], app)
        let field = app.textFields["Kode Verifikasi 6 Digit"]
        LiveFlow.type(try LiveFlow.waitForCode(after: sent), into: field, in: self, app: app)
        tap(app.buttons["Setuju dan Lanjut"], app, timeout: 20)
        tap(app.buttons["Lanjut"], app)
        LiveFlow.type("7500000", into: app.textFields["Penghasilan Bersih"], in: self, app: app)
        tap(app.buttons["Lanjut"], app)
        LiveFlow.type("4200000", into: app.textFields["Pengeluaran Pokok"], in: self, app: app)
        tap(app.buttons["Lanjut"], app)
        addPaylaterDebt(app)
        LiveFlow.type("4800000", into: app.textFields["Dana Darurat"], in: self, app: app)
        LiveFlow.type("600000", into: app.textFields["Menabung per Bulan"], in: self, app: app)
        tap(app.buttons["Lanjut"], app)
        tap(app.buttons["Lewati"], app)
        tap(app.buttons["Lihat Hasilku"], app)
        tap(app.buttons["Amankan Akunku"], app, timeout: 20)
        LiveFlow.type("381449", into: app.secureTextFields["Buat PIN 6 Angka"], in: self, app: app)
        tap(app.buttons["Buat PIN"], app)
        tap(app.buttons["Mulai"], app, timeout: 15)
        LiveFlow.expect(app.buttons["Beranda"], in: self, timeout: 20, app: app)
        LiveFlow.shot("v7-01-home", in: self)
    }

    @MainActor
    func test11CommunityJoinAndReport() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        LiveFlow.unlock(app)
        tap(app.buttons["Komunitas"], app, timeout: 20)
        LiveFlow.expect(app.staticTexts["Grup Pilihan"], in: self, timeout: 20, app: app)
        LiveFlow.shot("kom-01-list", in: self)
        tap(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Lunas Bareng'")).firstMatch, app)
        LiveFlow.expect(app.buttons["Gabung Grup"], in: self, timeout: 20, app: app)
        LiveFlow.shot("kom-02-group", in: self)
        tap(app.buttons["Gabung Grup"], app)
        tap(app.buttons["Aku sudah membaca dan setuju"], app)
        LiveFlow.shot("kom-03-rules", in: self)
        tap(app.buttons["Setuju dan Lanjut"], app)
        LiveFlow.expect(app.staticTexts["Belum Bisa Bergabung"], in: self, timeout: 20, app: app)
        LiveFlow.shot("kom-04-link-unavailable", in: self)
        tap(app.buttons["Tutup"], app)
        tap(app.buttons["Laporkan Grup"], app)
        tap(app.buttons["Lainnya"], app)
        tap(app.buttons["Kirim Laporan"], app)
        LiveFlow.expect(app.staticTexts["Wajib diisi untuk alasan Lainnya."], in: self, app: app)
        LiveFlow.shot("kom-05-other-needs-story", in: self)
        tap(app.buttons["Ajakan Gagal Bayar"], app)
        tap(app.buttons["Kirim Laporan"], app)
        LiveFlow.expect(app.staticTexts["Laporan Terkirim"], in: self, timeout: 20, app: app)
        LiveFlow.shot("kom-06-report-sent", in: self)
        tap(app.buttons["Selesai"], app)
        /** Selesai goes back to the list; the duplicate is reported from the group again. */
        tap(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Lunas Bareng'")).firstMatch, app, timeout: 20)
        tap(app.buttons["Laporkan Grup"], app, timeout: 20)
        tap(app.buttons["Ajakan Gagal Bayar"], app)
        tap(app.buttons["Kirim Laporan"], app)
        LiveFlow.expect(app.staticTexts["Grup Ini Sudah Kamu Laporkan"], in: self, timeout: 20, app: app)
        LiveFlow.shot("kom-07-report-duplicate", in: self)
    }

    @MainActor
    func test12MarketplaceProductAndSubmission() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        LiveFlow.unlock(app)
        tap(app.buttons["Komunitas"], app, timeout: 20)
        tap(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Etalase'")).firstMatch, app, timeout: 20)
        let course = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Kelas Budgeting'")).firstMatch
        LiveFlow.expect(course, in: self, timeout: 20, app: app)
        LiveFlow.shot("kom-08-marketplace", in: self)
        course.tap()
        let seller = app.buttons["Buka Halaman Penjual"]
        LiveFlow.expect(seller, in: self, timeout: 20, app: app)
        XCTAssertFalse(seller.isEnabled, "no seller URL until the curation team gives one")
        LiveFlow.shot("kom-09-product", in: self)
        tap(app.buttons["Kembali ke Etalase"], app)
        let submit = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Punya Produk'")).firstMatch
        for _ in 0..<4 where !submit.isHittable { app.swipeUp() }
        tap(submit, app)
        let send = app.buttons["Kirim Lewat Email"]
        LiveFlow.expect(send, in: self, app: app)
        if !send.isHittable { app.swipeUp() }
        send.tap()
        LiveFlow.expect(app.staticTexts["Aplikasi Email Belum Terbuka"], in: self, app: app)
        LiveFlow.shot("kom-10-submit-no-mail", in: self)
    }

    /** Utang: Paylater, then its details in the sheet. */
    @MainActor
    private func addPaylaterDebt(_ app: XCUIApplication) {
        tap(app.buttons["Paylater"], app)
        if !app.textFields["Nama Utang"].waitForExistence(timeout: 3) { tap(app.buttons["Tambah Rincian Utang"], app) }
        LiveFlow.type("Paylater B", into: app.textFields["Nama Utang"], in: self, app: app)
        LiveFlow.type("3000000", into: app.textFields["Sisa Utang"], in: self, app: app)
        LiveFlow.type("450000", into: app.textFields["Cicilan per Bulan"], in: self, app: app)
        LiveFlow.shot("onb-v7-debt", in: self)
        tap(app.buttons["Simpan Utang"], app)
        tap(app.buttons["Lanjut"], app)
    }

    @MainActor
    func tap(_ element: XCUIElement, _ app: XCUIApplication, timeout: TimeInterval = 10) {
        LiveFlow.tap(element, in: self, timeout: timeout, app: app)
    }
}
