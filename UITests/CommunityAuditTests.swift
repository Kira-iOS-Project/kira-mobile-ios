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
        try auditScreen(
            "communityOutbound",
            prepare: { app in
                tap("Gabung Grup", in: app)
                tap("Aku sudah membaca dan setuju", in: app)
                tap("Setuju dan Lanjut", in: app)
                XCTAssertTrue(app.buttons["Batal"].waitForExistence(timeout: 5))
            },
            accepting: { issue in
                /**
                 Accepted: "Potentially inaccessible text" with no element. Tautan Keluar is a half-height
                 sheet (TautanKeluar.dc.html, top 472), so Detail Grup's words stay visible above it under
                 the scrim while the modal cover keeps them out of reach on purpose (KiraCover hides the
                 screen behind a sheet); the audit reads those pixels as text no element carries. The
                 sheet's own texts are elements, so every finding with an element still fails.
                 */
                issue.element == nil && issue.compactDescription.hasPrefix("Potentially inaccessible text")
            })
    }

    @MainActor
    func testLinkUnavailablePassesTheAudit() throws {
        try auditScreen("communityLinkUnavailable") { app in
            tap("Gabung Grup", in: app)
            tap("Aku sudah membaca dan setuju", in: app)
            tap("Setuju dan Lanjut", in: app)
            XCTAssertTrue(app.buttons["Tutup"].waitForExistence(timeout: 5))
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
