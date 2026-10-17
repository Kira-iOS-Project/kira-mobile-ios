/**
 The rupiah field keeps every digit typed at full speed: XCUITest types all of "7500000" in one
 call, faster than any thumb, into Cek Kesehatan's income (ONB-10, `-KiraScreen income`). It once
 stored "750.000", a digit lost to a grouping written back after the keystroke.
 */
import XCTest

nonisolated final class AmountFieldTests: XCTestCase {
    @MainActor
    func testDigitsTypedInOneGoAreAllKept() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "income"]
        app.launch()
        let income = app.textFields["Penghasilan Bersih"]
        XCTAssertTrue(income.waitForExistence(timeout: 10))
        income.tap()
        income.typeText("7500000")
        XCTAssertEqual(income.value as? String, "7.500.000")
        income.typeText(XCUIKeyboardKey.delete.rawValue)
        XCTAssertEqual(income.value as? String, "750.000")
        income.typeText("9")
        XCTAssertEqual(income.value as? String, "7.500.009")
        app.terminate()
    }
}
