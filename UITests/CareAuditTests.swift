/**
 Rule 24 for PED: Kira Peduli (with the server's contacts and offline, on the shipped ones), its
 help sheet over the chat and Kirim Pesan ke Layanan Kira (with the sample Layanan Kira Peduli, and
 without it). Each screen opens through
 `-KiraScreen <name>` and is audited top to bottom (ScreenAudit.swift); the other tests check what
 the boards promise: one red button, no X on the sheet, nothing sent without a tap.
 */
import XCTest

nonisolated final class CareAuditTests: XCTestCase {
    @MainActor
    func testCarePassesTheAudit() throws {
        try auditScreen("care")
    }

    @MainActor
    func testCareOfflinePassesTheAudit() throws {
        try auditScreen("careOffline")
    }

    @MainActor
    func testTrustedMessageWithoutARecipientPassesTheAudit() throws {
        try auditScreen("trustedMessageNoRecipient")
    }

    /** With Layanan Kira's number, PED-04's three buttons are on. */
    @MainActor
    func testTrustedMessageSendsWithARecipient() throws {
        let app = launch("trustedMessage")
        let whatsApp = app.buttons["Kirim lewat WhatsApp"]
        XCTAssertTrue(whatsApp.waitForExistence(timeout: 5))
        XCTAssertTrue(whatsApp.isEnabled)
        XCTAssertTrue(app.buttons["Kirim lewat SMS"].isEnabled)
        XCTAssertTrue(app.buttons["Telepon Layanan Kira sekarang"].isEnabled)
        app.terminate()
    }

    @MainActor
    func testCareHelpPassesTheAudit() throws {
        try auditScreen("careHelp")
    }

    @MainActor
    func testTrustedMessagePassesTheAudit() throws {
        try auditScreen("trustedMessage")
    }

    /** With Layanan Kira Peduli in the list, its card shows and can be tapped. */
    @MainActor
    func testCareShowsLayananKiraWhenListed() throws {
        let app = launch("care")
        let card = app.buttons["Hubungi Layanan Kira. Pesan pembuka sudah disiapkan"]
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        XCTAssertTrue(card.isEnabled)
        app.terminate()
    }

    /** Offline, the shipped contacts still show; Layanan Kira, which has no number yet, does not. */
    @MainActor
    func testCareOfflineStillListsTheContacts() throws {
        let app = launch("careOffline")
        XCTAssertTrue(app.buttons["Telepon Healing119"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Chat Healing119"].exists)
        XCTAssertTrue(app.buttons["Telepon 119"].exists)
        XCTAssertTrue(app.buttons["Mode Darurat Utang"].exists)
        XCTAssertFalse(app.buttons["Hubungi Layanan Kira. Pesan pembuka sudah disiapkan"].exists)
        app.terminate()
    }

    /** The sheet has no X; Kembali ke Chat closes it and leaves the chat behind it. */
    @MainActor
    func testCareHelpClosesOnlyByKembaliKeChat() throws {
        let app = launch("careHelp")
        let title = app.staticTexts["Bicara dengan Orang Sekarang"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Tutup"].exists)
        XCTAssertTrue(app.buttons["Telepon 119"].exists)
        app.buttons["Kembali ke Chat"].tap()
        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
        app.terminate()
    }

    /** The swipe down closes the sheet too. */
    @MainActor
    func testCareHelpClosesBySwipe() throws {
        let app = launch("careHelp")
        let title = app.staticTexts["Bicara dengan Orang Sekarang"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        let top = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.29))
        top.press(forDuration: 0.05, thenDragTo: top.withOffset(CGVector(dx: 0, dy: 500)))
        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
        app.terminate()
    }

    /**
     Without Layanan Kira's number the message stays editable and nothing can be sent: the three
     buttons are off rather than opening an empty chat.
     */
    @MainActor
    func testTrustedMessageSendsNothingWithoutARecipient() throws {
        let app = launch("trustedMessageNoRecipient")
        let whatsApp = app.buttons["Kirim lewat WhatsApp"]
        XCTAssertTrue(whatsApp.waitForExistence(timeout: 5))
        XCTAssertFalse(whatsApp.isEnabled)
        XCTAssertFalse(app.buttons["Kirim lewat SMS"].isEnabled)
        XCTAssertFalse(app.buttons["Telepon Layanan Kira sekarang"].isEnabled)
        let field = app.textViews.firstMatch
        XCTAssertTrue(field.exists)
        XCTAssertEqual(field.value as? String, "Halo, aku lagi nggak baik-baik saja. Bisa dihubungi sekarang?")
        app.terminate()
    }

    @MainActor
    private func launch(_ screen: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", screen]
        app.launch()
        return app
    }
}
