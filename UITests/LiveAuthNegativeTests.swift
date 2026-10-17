/**
 The live auth negatives against a real local backend (LiveFlow.swift says how to run it), from a
 signed-out app: a wrong code shows `problem.AUTH_CODE_INVALID` and the fifth one
 `problem.AUTH_CODE_ATTEMPTS_EXCEEDED`; then a sign-in that the runner's script later expires
 (test02: the app refreshes once and goes on) and revokes (test03: the app is back at Masuk).
 Skipped unless KIRA_LIVE_SERVER is set. Each test is its own run, with the database step between.
 */
import XCTest

nonisolated final class LiveAuthNegativeTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func test01WrongCodesUntilTheAttemptsRunOut() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        requestCode(for: "neg.\(LiveFlow.email)", app)
        let field = app.textFields["Kode Verifikasi 6 Digit"]
        for attempt in 1...5 {
            LiveFlow.type(
                String(repeating: XCUIKeyboardKey.delete.rawValue, count: 6) + "00000\(attempt)",
                into: field, in: self, app: app)
            let message =
                attempt < 5
                ? "Kodenya belum cocok. Periksa lagi emailmu, ya."
                : "Kode ini sudah terlalu sering dicoba. Minta kode baru, ya."
            LiveFlow.expect(app.staticTexts[message], in: self, timeout: 20, app: app)
        }
        LiveFlow.shot("neg-01-attempts-exceeded", in: self)
    }

    @MainActor
    func test02SignInThenRefreshAnExpiredAccessToken() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        if app.buttons["Lupa PIN?"].waitForExistence(timeout: 5) {
            /** Second run, after the script expired the access token: Profil loads through a refresh. */
            LiveFlow.unlock(app)
            LiveFlow.tap(profile(app), in: self, timeout: 20, app: app)
            LiveFlow.expect(app.staticTexts["Email \(LiveFlow.email)"], in: self, timeout: 20, app: app)
            LiveFlow.shot("neg-03-refreshed", in: self)
            return
        }
        let sent = try LiveFlow.codes(for: LiveFlow.email).count
        requestCode(for: LiveFlow.email, app)
        LiveFlow.type(
            try LiveFlow.waitForCode(after: sent), into: app.textFields["Kode Verifikasi 6 Digit"],
            in: self, app: app)
        let pin = app.secureTextFields["Buat PIN 6 Angka"]
        if pin.waitForExistence(timeout: 15) {
            LiveFlow.type("381449", into: pin, in: self, app: app)
            LiveFlow.tap(app.buttons["Buat PIN"], in: self, app: app)
        }
        LiveFlow.unlock(app)
        LiveFlow.expect(profile(app), in: self, timeout: 20, app: app)
        LiveFlow.shot("neg-02-signed-in", in: self)
    }

    @MainActor
    func test03RevokedSessionIsBackAtMasuk() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        LiveFlow.unlock(app)
        let profile = profile(app)
        if profile.waitForExistence(timeout: 20) { profile.tap() }
        /** Signed out: Masuk ("Selamat Datang Kembali") or the intro that leads to it. */
        let signedOut = app.descendants(matching: .any).matching(
            NSPredicate(
                format: "label == 'Selamat Datang Kembali' OR label == 'Aku Sudah Punya Akun'")
        ).firstMatch
        LiveFlow.expect(signedOut, in: self, timeout: 30, app: app)
        LiveFlow.shot("neg-04-revoked", in: self)
    }

    @MainActor
    private func requestCode(for email: String, _ app: XCUIApplication) {
        LiveFlow.tap(app.buttons["Aku Sudah Punya Akun"], in: self, timeout: 20, app: app)
        LiveFlow.type(email, into: app.textFields["Email"], in: self, app: app)
        LiveFlow.tap(app.buttons["Kirim Kode Masuk"], in: self, app: app)
        LiveFlow.expect(app.textFields["Kode Verifikasi 6 Digit"], in: self, timeout: 20, app: app)
    }

    @MainActor
    private func profile(_ app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Profil'")).firstMatch
    }
}
