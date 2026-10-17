/**
 Rule 24 for KOM-06 to KOM-08: Etalase, Detail Produk of the four kinds, a product that is gone,
 and Kirim Produk with its dialog when no mail app opens (the simulator has none). Each screen opens
 through `-KiraScreen <name>` on the preview service and is audited top to bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class CommunityMarketplaceAuditTests: XCTestCase {
    @MainActor
    func testMarketplacePassesTheAudit() throws {
        try auditScreen("marketplace")
    }

    @MainActor
    func testMarketplaceChipFiltersTheProducts() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "marketplace"]
        app.launch()
        let course = app.buttons["Kelas Budgeting Gaji Pertama oleh Raka Aditya, Rp149.000,00"]
        let consultation = app.buttons["Pendampingan Negosiasi Utang oleh Dewi Anggraini, gratis"]
        XCTAssertTrue(course.waitForExistence(timeout: 10))
        XCTAssertTrue(consultation.exists)
        app.buttons["Konsultasi"].tap()
        XCTAssertTrue(consultation.waitForExistence(timeout: 5))
        XCTAssertFalse(course.exists)
        XCTAssertFalse(app.staticTexts["Rp0,00"].exists)
    }

    @MainActor
    func testMarketplaceEmptyPassesTheAudit() throws {
        try auditScreen(
            "marketplaceEmpty",
            prepare: { app in
                XCTAssertTrue(app.staticTexts["Belum ada produk di Etalase."].waitForExistence(timeout: 5))
            })
    }

    @MainActor
    func testMarketplaceFailedOffersRetryAndPassesTheAudit() throws {
        try auditScreen(
            "marketplaceFailed",
            prepare: { app in
                let message = app.staticTexts["Koneksi terputus. Cek internetmu, lalu coba lagi."]
                XCTAssertTrue(message.waitForExistence(timeout: 5))
                XCTAssertTrue(app.buttons["Coba Lagi"].exists)
            })
    }

    @MainActor
    func testProductCoursePassesTheAudit() throws {
        try auditScreen(
            "product",
            prepare: { app in
                let seller = app.buttons["Buka Halaman Penjual"]
                XCTAssertTrue(seller.waitForExistence(timeout: 5))
                XCTAssertTrue(seller.isEnabled)
            })
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
                XCTAssertFalse(app.buttons["Coba Lagi"].exists)
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
                XCTAssertTrue(app.buttons["Salin Alamat"].exists)
                XCTAssertTrue(app.buttons["Tutup"].exists)
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
