/**
 The live end-to-end tests' tools (LiveFlowTests and the files beside it): the app launched against
 a real local backend, the sign-in code read from that backend's log (it writes every email there
 when Resend is not configured), and a screenshot per step. Every live test is skipped unless
 `KIRA_LIVE_SERVER` is set (`TEST_RUNNER_KIRA_LIVE_SERVER` through xcodebuild), so CI stays
 offline. `KIRA_LIVE_LOG` is the backend's log file and `KIRA_LIVE_SHOTS` the folder the
 screenshots go to.
 */
import Foundation
import XCTest

nonisolated enum LiveFlow {
    private static var environment: [String: String] { ProcessInfo.processInfo.environment }

    /** The local backend's URL, or nil when the live tests should not run. */
    static var server: String? { environment["KIRA_LIVE_SERVER"] }

    /** Skips the test unless a live backend was given. */
    static func requireServer() throws -> String {
        guard let server else { throw XCTSkip("KIRA_LIVE_SERVER is not set: the live flow tests need a local backend") }
        return server
    }

    /** The address the run signs up with (`KIRA_LIVE_EMAIL`), new for each run. */
    static var email: String { environment["KIRA_LIVE_EMAIL"] ?? "live@kira.test" }

    /** The app, launched against `server`. */
    @MainActor
    static func launch(_ server: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraServer", server]
        app.launch()
        return app
    }

    /**
     The newest sign-in code mailed to `email`, read from the backend's log: the subject of the
     logged email is "<code> adalah kode masuk Kira" and its body names the address.
     */
    static func code(for email: String, after count: Int = 0) throws -> String {
        let codes = try codes(for: email)
        guard codes.count > count, let code = codes.last else {
            throw XCTSkip("no new sign-in code for \(email) in KIRA_LIVE_LOG")
        }
        return code
    }

    /** Every code mailed to `email`, oldest first. */
    static func codes(for email: String) throws -> [String] {
        guard let path = environment["KIRA_LIVE_LOG"] else { throw XCTSkip("KIRA_LIVE_LOG is not set") }
        let log = try String(contentsOfFile: path, encoding: .utf8)
        var found: [String] = []
        var subject: String?
        for line in log.split(separator: "\n") {
            if let range = line.range(of: #"\d{6} adalah kode masuk Kira"#, options: .regularExpression) {
                subject = String(line[range].prefix(6))
            } else if let code = subject, line.contains("dikirim ke \(email) ") {
                found.append(code)
                subject = nil
            }
        }
        return found
    }

    /** The code mailed after the `sent` ones before it, once the backend has logged it. */
    static func waitForCode(after sent: Int, for email: String = email) throws -> String {
        for _ in 0..<20 {
            if let code = try? code(for: email, after: sent) { return code }
            Thread.sleep(forTimeInterval: 0.5)
        }
        return try code(for: email, after: sent)
    }

    /** Saves a screenshot of the step as `<name>.png` in KIRA_LIVE_SHOTS, and attaches it. */
    @MainActor
    static func shot(_ name: String, in test: XCTestCase) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        test.add(attachment)
        if let folder = environment["KIRA_LIVE_SHOTS"] {
            try? screenshot.pngRepresentation.write(to: URL(filePath: folder).appending(path: "\(name).png"))
        }
    }

    /** Waits for `element` and taps it; on a miss, saves the screen and its element tree. */
    @MainActor
    static func tap(_ element: XCUIElement, in test: XCTestCase, timeout: TimeInterval = 10, app: XCUIApplication) {
        if !element.waitForExistence(timeout: timeout) { failure("\(test.name)", app: app, in: test) }
        XCTAssertTrue(element.exists, "missing \(element)")
        element.tap()
    }

    /** Waits for `element`, taps it and types `text`. */
    @MainActor
    static func type(_ text: String, into element: XCUIElement, in test: XCTestCase, app: XCUIApplication) {
        tap(element, in: test, app: app)
        /** A field in a rising sheet can miss the first tap's focus. */
        if !(element.value(forKey: "hasKeyboardFocus") as? Bool ?? true) { element.tap() }
        element.typeText(text)
    }

    /** Waits for `element` to appear; on a miss, saves the screen and its element tree. */
    @MainActor
    static func expect(_ element: XCUIElement, in test: XCTestCase, timeout: TimeInterval = 15, app: XCUIApplication) {
        if !element.waitForExistence(timeout: timeout) { failure("\(test.name)", app: app, in: test) }
        XCTAssertTrue(element.exists, "missing \(element)")
    }

    /**
     The dialog's button named `label`: the highest one on screen, since the screen behind a
     confirmation often has a button with the same name lower down (Hapus, Keluar).
     */
    @MainActor
    static func dialogButton(_ label: String, in app: XCUIApplication) -> XCUIElement {
        let matches = app.buttons.matching(NSPredicate(format: "label == %@", label))
        _ = matches.firstMatch.waitForExistence(timeout: 10)
        return matches.allElementsBoundByIndex.min { $0.frame.minY < $1.frame.minY } ?? matches.firstMatch
    }

    /** Opens Kira behind its lock with the run's PIN, when the lock shows. */
    @MainActor
    static func unlock(_ app: XCUIApplication, pin: String = "381449") {
        guard app.buttons["Lupa PIN?"].waitForExistence(timeout: 8) else { return }
        for digit in pin { app.buttons[String(digit)].tap() }
        if app.buttons["Buka Kira"].waitForExistence(timeout: 3) { app.buttons["Buka Kira"].tap() }
    }

    @MainActor
    private static func failure(_ name: String, app: XCUIApplication, in test: XCTestCase) {
        let safe = name.components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "-")
        shot("fail-\(safe)", in: test)
        if let folder = environment["KIRA_LIVE_SHOTS"] {
            try? app.debugDescription.write(
                to: URL(filePath: folder).appending(path: "fail-\(safe).txt"), atomically: true, encoding: .utf8)
        }
    }
}
