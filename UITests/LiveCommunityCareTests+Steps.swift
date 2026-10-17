/** The steps LiveCommunityCareTests+Care.swift repeats: opening Kira Peduli, a crisis phrase in Catat, a row. */
import XCTest

extension LiveCommunityCareTests {
    /** The board's message, which the on-device phrase list reads as danger. */
    static let crisisMessage = "tagihan numpuk semua, capek banget. kayaknya mending gak ada aja"

    /** Beranda's heart button, behind the PIN. */
    @MainActor
    func openCare() throws -> XCUIApplication {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        LiveFlow.unlock(app)
        tap(app.buttons["Butuh Bantuan Sekarang"].firstMatch, app, timeout: 20)
        LiveFlow.expect(app.staticTexts["Kira Peduli"], in: self, timeout: 20, app: app)
        return app
    }

    /** Catat with the board's crisis phrase sent, waiting for Kira's question. */
    @MainActor
    func sendCrisisMessage() throws -> XCUIApplication {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        LiveFlow.unlock(app)
        tap(app.buttons["Catat"], app, timeout: 20)
        sendCrisisPhrase(in: app)
        return app
    }

    /** Types the board's crisis phrase into Catat's composer and waits for Kira's question. */
    @MainActor
    func sendCrisisPhrase(in app: XCUIApplication) {
        let label = "Tulis Pengeluaran atau Pemasukan"
        let view = app.textViews[label].firstMatch
        let composer = view.waitForExistence(timeout: 10) ? view : app.textFields[label]
        LiveFlow.type(Self.crisisMessage, into: composer, in: self, app: app)
        tap(app.buttons["Kirim"], app)
        LiveFlow.expect(app.buttons["Aku Aman"].firstMatch, in: self, timeout: 20, app: app)
    }

    /** A list row or card whose label starts with `title`. */
    func rowStarting(_ title: String, _ app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", title)).firstMatch
    }
}
