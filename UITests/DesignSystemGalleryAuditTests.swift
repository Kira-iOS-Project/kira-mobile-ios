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
            try app.performAccessibilityAudit { issue in
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
        try app.performAccessibilityAudit()
        app.buttons["Tetap Berlangganan"].tap()
        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
        XCTAssertTrue(open.isHittable)
        app.terminate()
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
