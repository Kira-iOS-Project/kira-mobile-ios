/**
 The live walk of AKN, Paket and Beasiswa Kira against a real local backend (LiveFlow.swift says
 how to run it), on the account LiveFlowTests signed up: Profil, Keamanan, Data & Privasi, Beasiswa
 apply and withdraw, Paket, checkout (simulated), Langganan, Traktir, sign out and in again, and
 delete the account. Skipped unless KIRA_LIVE_SERVER is set. The tests run in order on one account.
 */
import XCTest

nonisolated final class LiveAccountTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func test01ProfileSecurityAndPrivacy() throws {
        let app = try openProfile()
        LiveFlow.shot("akn-01-profile", in: self)
        tap(row("Keamanan", app), app)
        LiveFlow.expect(app.staticTexts["Sembunyikan Saldo saat Membuka"], in: self, app: app)
        LiveFlow.shot("akn-03-security", in: self)
        tap(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Kembali'")).firstMatch, app)
        tap(row("Data & Privasi", app), app)
        LiveFlow.expect(app.staticTexts["Unduh Datamu"], in: self, app: app)
        LiveFlow.shot("akn-04-privacy", in: self)
    }

    @MainActor
    func test02ScholarshipApplyAndWithdraw() throws {
        let app = try openPlans()
        app.swipeUp()
        tap(row("Beasiswa Kira", app), app)
        tap(row("Ajukan Beasiswa", app), app)
        tap(row("Ditagih Pinjol", app), app)
        LiveFlow.shot("akn-05-scholarship-apply", in: self)
        tap(row("Kirim Pengajuan", app), app)
        tap(row("Lihat Status", app), app, timeout: 20)
        LiveFlow.shot("akn-06-scholarship-pending", in: self)
        tap(row("Tarik Pengajuan", app), app)
        LiveFlow.expect(row("Ajukan Beasiswa", app), in: self, timeout: 20, app: app)
        LiveFlow.shot("akn-07-scholarship-withdrawn", in: self)
    }

    @MainActor
    func test03CheckoutSubscriptionAndTreat() throws {
        let app = try openPlans()
        tap(app.buttons.matching(NSPredicate(format: "label CONTAINS 'Kira Plus'")).firstMatch, app)
        LiveFlow.shot("akn-08-plan-detail", in: self)
        tap(row("Coba Kira Plus", app), app)
        let pay = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Bayar'")).firstMatch
        tap(pay, app)
        tap(row("Selesai", app), app, timeout: 20)
        LiveFlow.expect(row("Batalkan Langganan", app), in: self, timeout: 20, app: app)
        LiveFlow.shot("akn-09-subscription", in: self)
        tap(row("Batalkan Langganan", app), app)
        confirm("Batalkan Langganan", in: "Batalkan Langganan?", app)
        LiveFlow.expect(app.staticTexts["Langganan Dibatalkan"], in: self, timeout: 20, app: app)
        LiveFlow.shot("akn-10-cancelled", in: self)
        tap(row("Selesai", app), app)
        tap(row("Traktir Kira", app), app)
        tap(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Traktir Rp'")).firstMatch, app)
        LiveFlow.expect(row("Selesai", app), in: self, timeout: 20, app: app)
        LiveFlow.shot("akn-10b-treat", in: self)
    }

    @MainActor
    func test04SignOutAndBackIn() throws {
        let app = try openProfile()
        app.swipeUp()
        app.swipeUp()
        tap(row("Keluar", app), app)
        confirm("Keluar", in: "Keluar dari Kira?", app)
        LiveFlow.shot("akn-11-signed-out", in: self)
        tap(row("Aku Sudah Punya Akun", app), app, timeout: 20)
        let sent = try LiveFlow.codes(for: LiveFlow.email).count
        LiveFlow.type(LiveFlow.email, into: app.textFields["Email"], in: self, app: app)
        tap(row("Kirim Kode", app), app)
        LiveFlow.type(
            try LiveFlow.waitForCode(after: sent), into: app.textFields["Kode Verifikasi 6 Digit"], in: self, app: app)
        LiveFlow.shot("akn-12-signed-in-again", in: self)
        let pin = app.secureTextFields["Buat PIN 6 Angka"]
        if pin.waitForExistence(timeout: 15) {
            LiveFlow.type("381449", into: pin, in: self, app: app)
            tap(row("Buat PIN", app), app)
        }
        LiveFlow.unlock(app)
        LiveFlow.expect(row("Beranda", app), in: self, timeout: 20, app: app)
    }

    @MainActor
    func test05DeleteTheAccount() throws {
        let app = try openProfile()
        tap(row("Data & Privasi", app), app)
        app.swipeUp()
        tap(row("Hapus Akun dan Data", app), app)
        LiveFlow.type("HAPUS", into: app.textFields["Ketik HAPUS untuk Konfirmasi"], in: self, app: app)
        LiveFlow.shot("akn-13-delete", in: self)
        tap(row("Hapus Permanen", app), app)
        tap(row("Selesai", app), app, timeout: 20)
        LiveFlow.shot("akn-14-deleted", in: self)
    }

    @MainActor
    private func openProfile() throws -> XCUIApplication {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        LiveFlow.unlock(app)
        tap(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Profil'")).firstMatch, app, timeout: 20)
        return app
    }

    @MainActor
    private func openPlans() throws -> XCUIApplication {
        let app = try openProfile()
        tap(row("Lihat Paket", app), app)
        return app
    }

    /** The button titled `title`; a list row's label adds its subtitle ("Keamanan, Kunci PIN aktif"). */
    @MainActor
    private func row(_ title: String, _ app: XCUIApplication) -> XCUIElement {
        rows(title, app).firstMatch
    }

    @MainActor
    private func rows(_ title: String, _ app: XCUIApplication) -> XCUIElementQuery {
        app.buttons.matching(NSPredicate(format: "label == %@ OR label BEGINSWITH %@", title, "\(title), "))
    }

    /**
     The confirm of the dialog titled `dialog`, which repeats the title of the button that opened it:
     the match just under the dialog's title, not the button behind the dialog.
     */
    @MainActor
    private func confirm(_ title: String, in dialog: String, _ app: XCUIApplication) {
        let heading = app.staticTexts[dialog]
        LiveFlow.expect(heading, in: self, app: app)
        let top = heading.frame.maxY
        let below = rows(title, app).allElementsBoundByIndex.filter { $0.frame.minY > top }
        guard let button = below.min(by: { $0.frame.minY < $1.frame.minY }) else {
            return XCTFail("no \(title) under \(dialog)")
        }
        button.tap()
    }

    @MainActor
    private func tap(_ element: XCUIElement, _ app: XCUIApplication, timeout: TimeInterval = 10) {
        LiveFlow.tap(element, in: self, timeout: timeout, app: app)
    }
}
