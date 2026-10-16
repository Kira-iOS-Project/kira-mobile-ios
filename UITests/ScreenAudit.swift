/**
 The accessibility audit of one screen opened by the debug-only `-KiraScreen <name>` launch
 argument (App/Launch/ScreenLaunch.swift), as Rule 24 asks for every primary screen. The audit
 reads only what is on screen, so a long screen is audited, scrolled about two thirds of a screen,
 and audited again until its last element is in view. An audit that runs out of time is made once
 more; any finding fails unless the screen's test accepts it with a comment giving the reason
 (.claude/rules/ios/testing.md).
 */
import XCTest

extension XCTestCase {
    /**
     Launches `screen`, waits for it, lets `prepare` open what the screen shows over itself (a sheet,
     a panel), and audits it top to bottom.
     */
    @MainActor
    func auditScreen(
        _ screen: String, prepare: (XCUIApplication) -> Void = { _ in },
        accepting accepted: @escaping (XCUIAccessibilityAuditIssue) -> Bool = { _ in false }
    ) throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", screen]
        app.launch()
        try waitUntilLoaded(app)
        prepare(app)
        Thread.sleep(forTimeInterval: 1)
        let window = app.windows.firstMatch.frame
        let scroll = app.scrollViews.firstMatch
        for pass in 0..<8 {
            if pass > 0 {
                guard scroll.exists, !lastElementIsVisible(in: scroll, window: window) else { break }
                scrollDown(scroll)
            }
            try XCTContext.runActivity(named: "\(screen), pass \(pass + 1)") { _ in
                try auditRetryingTimeout(app) { issue in
                    let ok = Self.isAcceptedEverywhere(issue, window: window) || accepted(issue)
                    NSLog("AUDITLOG %@ ok=%d type=%ld label=[%@] id=[%@] frame=%@ desc=%@", screen, ok ? 1 : 0, issue.auditType.rawValue, issue.element?.label ?? "-", issue.element?.identifier ?? "-", NSCoder.string(for: issue.element?.frame ?? .zero), issue.compactDescription)
                    return ok
                }
            }
        }
        app.terminate()
    }

    /**
     The findings every screen accepts, each an owner's decision recorded in docs/design-system.md.
     */
    private static func isAcceptedEverywhere(_ issue: XCUIAccessibilityAuditIssue, window: CGRect) -> Bool {
        /**
         Accepted deviation: the design system's own small sizes (the 11 pt overline, the medium
         amount's 11 pt "Rp" and ",00", the 11 pt bar caption) are reported as partial Dynamic Type
         support; those texts carry `kira.small-type`.
         */
        if issue.auditType == .dynamicType, issue.element?.identifier == "kira.small-type" { return true }
        /**
         Accepted: a contrast finding on an element a scroll has left under the status bar or at the
         home indicator, where the audit samples the bar instead of the text's own background.
         */
        guard issue.auditType == .contrast, let frame = issue.element?.frame else { return false }
        return frame.minY < window.minY + 100 || frame.maxY > window.maxY - 50
    }

    /** Waits until the screen exists and no preview service is still answering (its placeholder). */
    @MainActor
    private func waitUntilLoaded(_ app: XCUIApplication) throws {
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        XCTAssertTrue(app.staticTexts.firstMatch.waitForExistence(timeout: 10))
        let settled = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "count == 0"), object: app.activityIndicators)
        XCTAssertEqual(XCTWaiter().wait(for: [settled], timeout: 10), .completed)
        /** The previews answer after a short pause and the redacted placeholder fades out. */
        Thread.sleep(forTimeInterval: 1.5)
    }

    /** Whether the bottom of the scroll view's content is already on screen. */
    @MainActor
    private func lastElementIsVisible(in scroll: XCUIElement, window: CGRect) -> Bool {
        let bottoms = [scroll.staticTexts, scroll.buttons].compactMap { query -> CGFloat? in
            let count = query.count
            return count > 0 ? query.element(boundBy: count - 1).frame.maxY : nil
        }
        return (bottoms.max() ?? 0) <= min(scroll.frame.maxY, window.maxY)
    }

    /**
     One audit, made once more only when Apple's audit could not finish in time (XCTest's code -56):
     the tool timing out, not a finding. Any finding fails at once, and so does a second timeout.
     */
    @MainActor
    private func auditRetryingTimeout(_ app: XCUIApplication, accepting accepted: @escaping (XCUIAccessibilityAuditIssue) -> Bool) throws {
        do {
            try app.performAccessibilityAudit(accepted)
        } catch let error as NSError
            where error.domain == "com.apple.xcode.xctest.accessibilityAudit" && error.code == -56
        {
            XCTContext.runActivity(named: "The audit did not finish in time; running it once more") { _ in }
            try app.performAccessibilityAudit(accepted)
        }
    }

    /**
     Scrolls about two thirds of a screen with a drag that holds still before lifting, then lets the
     page settle, so the audit never reads moving text.
     */
    @MainActor
    private func scrollDown(_ scroll: XCUIElement) {
        let start = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
        let end = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .default, thenHoldForDuration: 0.5)
        Thread.sleep(forTimeInterval: 1)
    }
}
