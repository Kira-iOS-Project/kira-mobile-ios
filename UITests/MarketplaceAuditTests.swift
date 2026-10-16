/**
 Rule 24 for KOM-06 to KOM-08: Etalase, Detail Produk of the four kinds, a product that is gone,
 and Kirim Produk with its dialog when no mail app opens (the simulator has none). Each screen opens
 through `-KiraScreen <name>` on the preview service and is audited top to bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class MarketplaceAuditTests: XCTestCase {
    @MainActor
    func testMarketplacePassesTheAudit() throws {
        try auditScreen("marketplace")
    }

    @MainActor
    func testMarketplaceChipFiltersTheProducts() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "marketplace"]
        app.launch()
        XCTAssertTrue(app.buttons["Kelas Budgeting Gaji Pertama oleh Raka Aditya, Rp149.000,00"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Pendampingan Negosiasi Utang oleh Dewi Anggraini, gratis"].exists)
        app.buttons["Konsultasi"].tap()
        XCTAssertTrue(app.buttons["Pendampingan Negosiasi Utang oleh Dewi Anggraini, gratis"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Kelas Budgeting Gaji Pertama oleh Raka Aditya, Rp149.000,00"].exists)
        XCTAssertFalse(app.staticTexts["Rp0,00"].exists)
    }

    @MainActor
    func testProductCoursePassesTheAudit() throws {
        try auditScreen("product")
    }

    @MainActor
    func testProductConsultationPassesTheAudit() throws {
        try auditScreen("productConsultation")
    }

    @MainActor
    func testProductEbookPassesTheAudit() throws {
        try auditScreen("productEbook")
    }

    @MainActor
    func testProductEventPassesTheAudit() throws {
        try auditScreen("productEvent")
    }

    @MainActor
    func testProductGoneShowsItsMessageAndPassesTheAudit() throws {
        try auditScreen(
            "productGone",
            prepare: { app in
                XCTAssertTrue(app.staticTexts["Produk ini sudah tidak ada di Etalase."].waitForExistence(timeout: 5))
                XCTAssertTrue(app.buttons["Coba Lagi"].exists)
                XCTAssertTrue(app.buttons["Kembali ke Etalase"].exists)
            })
    }

    @MainActor
    func testSubmitProductPassesTheAudit() throws {
        try auditScreen("submitProduct")
    }

    @MainActor
    func testSubmitProductWithoutMailAppShowsTheDialog() throws {
        try auditScreen(
            "submitProduct",
            prepare: { app in
                let send = app.buttons["Kirim Lewat Email"]
                if !send.isHittable { app.swipeUp() }
                send.tap()
                XCTAssertTrue(app.staticTexts["Aplikasi Email Belum Terbuka"].waitForExistence(timeout: 5))
            },
            accepting: { issue in
                /**
                 Accepted, as the gallery's presented-dialog test does: the dimmed screen's text behind
                 the scrim, which VoiceOver rightly cannot reach while the dialog is modal.
                 */
                issue.auditType == .elementDetection && issue.element == nil
            })
    }
}
