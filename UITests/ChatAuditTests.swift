/**
 Rule 24 for Catat (CAT-01 to CAT-09): the chat, and what it opens over itself from the composer:
 the drafts sheet, Catat Manual, the dark Scan Struk camera (the simulator has no camera feed, so the
 audit reads what renders over it), Kuota AI and the voice panel. Each opens through
 `-KiraScreen <name>` and a tap (ScreenAudit.swift).
 */
import XCTest

nonisolated final class ChatAuditTests: XCTestCase {
    @MainActor
    func testRecordPassesTheAudit() throws {
        try auditScreen("record")
    }

    /** EditDraf: the pencil of a draft item opens the drafts sheet. */
    @MainActor
    func testDraftsSheetPassesTheAudit() throws {
        try auditScreen("recordDrafts") { app in
            Self.tap(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Ubah '")).firstMatch)
            XCTAssertTrue(app.staticTexts["Ubah Transaksi"].waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testManualEntryPassesTheAudit() throws {
        try auditScreen("recordManual") { app in
            Self.tap(app.buttons["Catat manual, isi formulir"])
            XCTAssertTrue(app.staticTexts["Catat Manual"].waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testReceiptScanPassesTheAudit() throws {
        try auditScreen("recordScan") { app in
            Self.tap(app.buttons["Foto struk atau pilih screenshot"])
            XCTAssertTrue(app.staticTexts["Scan Struk"].waitForExistence(timeout: 5))
        }
    }

    /** Kuota AI: the receipts are used up, so the camera opens the quota sheet. */
    @MainActor
    func testQuotaSheetPassesTheAudit() throws {
        try auditScreen("recordQuota") { app in
            Self.tap(app.buttons["Foto struk atau pilih screenshot"])
            XCTAssertTrue(app.staticTexts["Kuota AI"].waitForExistence(timeout: 5))
        }
    }

    /** InputSuara on Kira Plus: the microphone opens the voice panel. */
    @MainActor
    func testVoicePanelPassesTheAudit() throws {
        try auditScreen("recordVoice") { app in
            Self.tap(app.buttons["Catat dengan suara"])
            XCTAssertTrue(app.buttons["Berhenti merekam"].waitForExistence(timeout: 5))
        }
    }

    @MainActor
    private static func tap(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        element.tap()
    }
}
