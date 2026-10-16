/**
 Apple's accessibility audit over the design system gallery (debug builds only), page by page, so
 every component is checked in place for its VoiceOver names, contrast, Dynamic Type support,
 clipped text and touch targets before a screen uses it. Each page opens straight from the launch
 arguments (`-KiraGallery <page>`), and the audit runs again after each scroll, because it reads
 only what is on screen.
 */
import XCTest

nonisolated final class DesignSystemGalleryAuditTests: XCTestCase {
    /** GalleryPage's raw values, in the order the gallery lists them; "" is the list of pages. */
    private static let pages = [
        "", "colors", "type", "icons", "brand", "categories", "illustrations", "nature", "buttons", "forms",
        "entry", "labels", "amounts", "progress", "score", "lists", "navigation", "dialogs", "chat",
    ]
    /** Pages taller than three screens, which take more scrolls to audit all the way down. */
    private static let tallPages: Set = ["dialogs"]

    @MainActor
    func testEveryGalleryPagePassesTheAudit() throws {
        for page in Self.pages {
            try XCTContext.runActivity(named: page.isEmpty ? "pages" : page) { _ in try audit(page: page) }
        }
    }

    @MainActor
    private func audit(page: String) throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraGallery"] + (page.isEmpty ? [] : [page])
        app.launch()
        let scroll = app.scrollViews.firstMatch
        XCTAssertTrue(scroll.waitForExistence(timeout: 10))
        let screen = app.windows.firstMatch.frame
        for pass in 0..<(Self.tallPages.contains(page) ? 5 : 3) {
            if pass > 0 { scrollDown(scroll) }
            try audit(app) { issue in
                /**
                 Listed apart, an accepted deviation the owner chose: the partial Dynamic Type support
                 the audit reports for the design system's own small sizes (the 11 pt overline, the
                 medium amount's 11 pt "Rp" and ",00", the 10 pt Catat label, the 11 pt bar
                 caption), which those texts carry as `kira.small-type` (docs/design-system.md).
                 */
                if issue.auditType == .dynamicType, issue.element?.identifier == "kira.small-type" { return true }
                /**
                 Accepted: a contrast finding on an element a scroll has left under the status bar
                 or at the home indicator, where the audit samples the bar instead of the text's
                 own background. Every element away from those edges is still checked.
                 */
                guard issue.auditType == .contrast, let frame = issue.element?.frame else { return false }
                return frame.minY < screen.minY + 100 || frame.maxY > screen.maxY - 50
            }
        }
        app.terminate()
    }

    /**
     A dialog presented from the gallery: audited over the whole window, then closed by its
     secondary button, which leaves the page as it was.
     */
    @MainActor
    func testPresentedDialogPassesTheAuditAndCloses() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraGallery", "dialogs"]
        app.launch()
        let open = app.buttons["Buka Dialog"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        open.tap()
        let title = app.staticTexts["Batalkan Langganan?"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        try audit(app) { issue in
            /**
             Accepted: the screen behind shows through the scrim, and its text, which VoiceOver
             rightly cannot reach while the dialog is modal, reads as text without an element. The
             audit names no element for it; any finding on an element still fails.
             */
            issue.auditType == .elementDetection && issue.element == nil
        }
        app.buttons["Tetap Berlangganan"].tap()
        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
        XCTAssertTrue(open.isHittable)
        app.terminate()
    }

    @MainActor
    func testBudgetSaveFailureDialogPassesAuditAndKeepsDraftOnRetry() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraGallery", "dialogs"]
        app.launch()

        let scroll = app.scrollViews.firstMatch
        XCTAssertTrue(scroll.waitForExistence(timeout: 10))
        let open = app.buttons["Uji Gagal Menyimpan Budget"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        for _ in 0..<5 where !open.isHittable { scrollDown(scroll) }
        XCTAssertTrue(open.isHittable)

        let amount = app.textFields["Alokasi Budget"]
        XCTAssertTrue(amount.exists)
        open.tap()

        let title = app.staticTexts["Belum Berhasil Menyimpan"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts[
                "Koneksi terputus. Angka budgetmu tetap ada di layar. Sambungkan koneksi lalu coba lagi."
            ].exists)
        XCTAssertTrue(app.buttons["Tutup"].exists)
        try audit(app) { issue in issue.auditType == .elementDetection && issue.element == nil }
        let retry = app.buttons.matching(
            NSPredicate(format: "label == %@ AND isHittable == true", "Coba Lagi")
        ).firstMatch
        XCTAssertTrue(retry.waitForExistence(timeout: 5))
        retry.tap()

        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
        XCTAssertEqual(amount.value as? String, "350000")
        XCTAssertTrue(app.staticTexts["Percobaan ulang dipanggil."].exists)

        open.tap()
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        let close = app.buttons.matching(
            NSPredicate(format: "label == %@ AND isHittable == true", "Tutup")
        ).firstMatch
        XCTAssertTrue(close.waitForExistence(timeout: 5))
        close.tap()
        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
        XCTAssertEqual(amount.value as? String, "350000")
        app.terminate()
    }

    /**
     One accessibility audit, made once more only when Apple's audit could not finish in time
     (XCTest's code -56). On a slow CI runner a long page can outlast the audit's own time limit:
     that is the tool timing out, not a finding. Any finding fails at once, and so does a second
     timeout (.claude/rules/ios/testing.md, Rule 24).
     */
    @MainActor
    private func audit(
        _ app: XCUIApplication,
        accepting accepted: @escaping (XCUIAccessibilityAuditIssue) throws -> Bool
    ) throws {
        do {
            try app.performAccessibilityAudit(accepted)
        } catch let error as NSError where Self.auditTimedOut(error) {
            XCTContext.runActivity(named: "The audit did not finish in time; running it once more") { _ in }
            try app.performAccessibilityAudit(accepted)
        }
    }

    /** XCTest's "Audit failed to complete in time": the audit stopped before it read the whole screen. */
    private static func auditTimedOut(_ error: NSError) -> Bool {
        error.domain == "com.apple.xcode.xctest.accessibilityAudit" && error.code == -56
    }

    /**
     Scrolls about two thirds of a screen with a drag that holds still before lifting, so the page
     has stopped when the audit reads it: a swipe leaves it gliding, and the audit then reads
     moving text as low contrast.
     */
    @MainActor
    private func scrollDown(_ scroll: XCUIElement) {
        let start = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
        let end = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .default, thenHoldForDuration: 0.5)
    }
}
