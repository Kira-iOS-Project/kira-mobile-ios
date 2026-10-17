/**
 A rupiah field (`.amount()`, a UITextField inside KiraField) is one line of its font tall, never
 stretched by the layout around it: on Kuis Penghasilan it once filled 221 pt of the step.
 */
import XCTest

nonisolated final class AmountFieldSizeTests: XCTestCase {
    @MainActor
    func testQuizAmountFieldIsOneLineTall() {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "income"]
        app.launch()
        let amount = app.textFields["Penghasilan Bersih"]
        XCTAssertTrue(amount.waitForExistence(timeout: 10))
        XCTAssertLessThanOrEqual(amount.frame.height, 34, "amount field \(amount.frame.height) pt tall")
        app.terminate()
    }
}
