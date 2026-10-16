/**
 The live walk of ONB, BRD and SKR against a real local backend (LiveFlow.swift says how to run
 it): sign up with the code from the backend's log, consent, focus, the six quiz steps, the
 result, the PIN and Beranda; then Kira Score and an indicator. Skipped unless KIRA_LIVE_SERVER is
 set. The tests run in order on one account: each later one starts behind the PIN.
 */
import XCTest

nonisolated final class LiveFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func test01SignUpThroughTheHealthCheckToBeranda() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        tap(app.buttons["Lewati"], app)
        tap(app.buttons["Daftar dengan Email"], app)
        let sent = try LiveFlow.codes(for: LiveFlow.email).count
        LiveFlow.type(LiveFlow.email, into: app.textFields["Email"], in: self, app: app)
        tap(app.buttons["Kirim Kode"], app)
        let field = app.textFields["Kode Verifikasi 6 Digit"]
        LiveFlow.expect(field, in: self, app: app)
        LiveFlow.shot("onb-01-code", in: self)
        LiveFlow.type(try LiveFlow.waitForCode(after: sent), into: field, in: self, app: app)
        tap(app.buttons["Setuju dan Lanjut"], app, timeout: 20)
        LiveFlow.shot("onb-02-focus", in: self)
        tap(app.buttons["Lanjut"], app)
        answerQuiz(app)
        tap(app.buttons["Amankan Akunku"], app, timeout: 20)
        LiveFlow.shot("onb-05-pin", in: self)
        LiveFlow.type("381449", into: app.secureTextFields["Buat PIN 6 Angka"], in: self, app: app)
        tap(app.buttons["Buat PIN"], app)
        tap(app.buttons["Mulai"], app, timeout: 15)
        LiveFlow.expect(app.buttons["Beranda"], in: self, timeout: 20, app: app)
        LiveFlow.shot("brd-01-home", in: self)
    }

    @MainActor
    func test02KiraScoreAndAnIndicator() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        LiveFlow.unlock(app)
        LiveFlow.shot("akn-02-unlocked", in: self)
        tap(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Kira Score'")).firstMatch, app, timeout: 20)
        LiveFlow.expect(app.staticTexts["Kira Score"], in: self, app: app)
        LiveFlow.shot("skr-01-score", in: self)
        let indicator = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Dana Darurat'")).firstMatch
        app.swipeUp()
        tap(indicator, app)
        LiveFlow.expect(app.staticTexts["Aturan Nilai"], in: self, app: app)
        LiveFlow.shot("skr-02-indicator", in: self)
    }

    @MainActor
    private func answerQuiz(_ app: XCUIApplication) {
        LiveFlow.type("7500000", into: app.textFields["Penghasilan Bersih"], in: self, app: app)
        LiveFlow.shot("onb-03-income", in: self)
        tap(app.buttons["Lanjut"], app)
        LiveFlow.type("4200000", into: app.textFields["Pengeluaran Pokok"], in: self, app: app)
        tap(app.buttons["Lanjut"], app)
        tap(app.buttons["Isi Nanti"], app)
        LiveFlow.type("4800000", into: app.textFields["Dana Darurat"], in: self, app: app)
        LiveFlow.type("600000", into: app.textFields["Menabung per Bulan"], in: self, app: app)
        tap(app.buttons["Lanjut"], app)
        tap(app.buttons["Lewati"], app)
        LiveFlow.shot("onb-04-protection", in: self)
        tap(app.buttons["Lihat Hasilku"], app)
    }

    @MainActor
    private func tap(_ element: XCUIElement, _ app: XCUIApplication, timeout: TimeInterval = 10) {
        LiveFlow.tap(element, in: self, timeout: timeout, app: app)
    }
}
