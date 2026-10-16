/**
 Rule 24 for KOM: Komunitas, Detail Grup, and the sheets and dialogs Detail Grup opens. Each screen
 opens through `-KiraScreen <name>`; a sheet or a dialog is opened by tapping as a person would, and
 audited top to bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class CommunityAuditTests: XCTestCase {
    @MainActor
    func testCommunityPassesTheAudit() throws {
        try auditScreen("community")
    }

    @MainActor
    func testGroupPassesTheAudit() throws {
        try auditScreen("communityGroup")
    }

    @MainActor
    func testRulesPassesTheAudit() throws {
        try auditScreen("communityRules") { app in
            tap("Gabung Grup", in: app)
            XCTAssertTrue(app.buttons["Setuju dan Lanjut"].waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testOutboundLinkPassesTheAudit() throws {
        try auditScreen("communityOutbound") { app in
            tap("Gabung Grup", in: app)
            tap("Aku Sudah Membaca dan Setuju", in: app)
            tap("Setuju dan Lanjut", in: app)
            XCTAssertTrue(app.buttons["Batal"].waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testReportPassesTheAudit() throws {
        try auditScreen("groupReport") { app in
            tap("Laporkan Grup", in: app)
            tap("Ajakan Gagal Bayar", in: app)
        }
    }

    @MainActor
    func testReportOtherPassesTheAudit() throws {
        try auditScreen("groupReportOther") { app in
            tap("Laporkan Grup", in: app)
            tap("Lainnya", in: app)
        }
    }

    @MainActor
    func testReportSentPassesTheAudit() throws {
        try auditScreen("groupReportSent") { app in
            sendReport(in: app)
            XCTAssertTrue(app.buttons["Selesai"].waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testReportFailedPassesTheAudit() throws {
        try auditScreen("groupReportFailed") { app in
            sendReport(in: app)
            XCTAssertTrue(app.buttons["Coba Lagi"].waitForExistence(timeout: 5))
        }
    }

    /** Laporkan Grup with "Ajakan Gagal Bayar", sent. */
    @MainActor
    private func sendReport(in app: XCUIApplication) {
        tap("Laporkan Grup", in: app)
        tap("Ajakan Gagal Bayar", in: app)
        tap("Kirim Laporan", in: app)
    }

    /** Waits for the button labelled `label` and taps it. */
    @MainActor
    private func tap(_ label: String, in app: XCUIApplication) {
        let button = app.buttons[label].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 5), "no \(label)")
        button.tap()
    }
}
