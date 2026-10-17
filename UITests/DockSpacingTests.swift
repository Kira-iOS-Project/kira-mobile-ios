/**
 The floating dock never covers a screen's last block: scrolled to the bottom, Beranda's content ends
 40 pt (space10) above the dock, and Catat's composer still sits clear of it.
 */
import XCTest

nonisolated final class DockSpacingTests: XCTestCase {
    @MainActor
    func testBerandaEndsAboveTheDock() {
        let app = openMain()
        let dock = app.otherElements["Navigasi utama"]
        XCTAssertTrue(dock.waitForExistence(timeout: 15))
        for _ in 0..<6 { app.swipeUp(velocity: .fast) }
        Thread.sleep(forTimeInterval: 1)
        let top = dock.frame.minY
        let bottom = lowestContent(in: app, above: app.windows.firstMatch.frame.maxY, excluding: dock.frame)
        XCTContext.runActivity(named: "dock top \(top), content bottom \(bottom), dock \(dock.frame)") { _ in }
        XCTAssertLessThanOrEqual(bottom, top - 40 + 1, "content ends at \(bottom), dock starts at \(top)")
        app.terminate()
    }

    @MainActor
    func testCatatComposerSitsAboveTheDock() {
        let app = openMain()
        let dock = app.otherElements["Navigasi utama"]
        XCTAssertTrue(dock.waitForExistence(timeout: 15))
        app.buttons["Catat"].firstMatch.tap()
        let label = "Tulis Pengeluaran atau Pemasukan"
        let field = app.textViews[label].firstMatch
        let composer = field.waitForExistence(timeout: 10) ? field : app.textFields[label]
        XCTAssertTrue(composer.waitForExistence(timeout: 5))
        XCTContext.runActivity(named: "composer \(composer.frame), dock \(dock.frame)") { _ in }
        XCTAssertLessThanOrEqual(composer.frame.maxY, dock.frame.minY, "the composer is under the dock")
        app.terminate()
    }

    /** Signed in on the sample data, past the lock: the app's own tabs and dock. */
    @MainActor
    private func openMain() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraPreviewServices", "-KiraLocked"]
        app.launch()
        if app.buttons["Lupa PIN?"].waitForExistence(timeout: 10) {
            for digit in "381449" { app.buttons[String(digit)].tap() }
            if app.buttons["Buka Kira"].waitForExistence(timeout: 3) { app.buttons["Buka Kira"].tap() }
        }
        return app
    }

    /** The lowest edge of any text or button on screen that is not part of the dock. */
    @MainActor
    private func lowestContent(in app: XCUIApplication, above limit: CGFloat, excluding dock: CGRect) -> CGFloat {
        var lowest: CGFloat = 0
        for query in [app.staticTexts, app.buttons] {
            for frame in query.allElementsBoundByIndex.map(\.frame)
            where frame.height > 0 && frame.minY < limit && !dock.contains(frame) {
                lowest = max(lowest, min(frame.maxY, limit))
            }
        }
        return lowest
    }
}
