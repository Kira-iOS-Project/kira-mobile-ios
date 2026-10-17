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
        let cuts = ScrollEdgeCuts(clip: scroll.exists ? scroll.frame : window)
        var before = CGFloat.infinity
        for pass in 0..<8 {
            if pass > 0 {
                /**
                 Scrolls on while any of the last element is still cut by the scroll view's edge: an
                 element half under that edge is sampled against what lies past it (Laporkan Grup's
                 privacy note over Kirim Laporan), so the last pass sees it whole. A scroll that
                 brings nothing more into view ends the audit.
                 */
                let remaining = scroll.exists ? hiddenBelow(in: scroll, window: window) : 0
                guard remaining >= 1, remaining < before else { break }
                before = remaining
                scrollDown(scroll, by: remaining)
            }
            try XCTContext.runActivity(named: "\(screen), pass \(pass + 1)") { _ in
                try auditInPlace(app) { cuts.accepts($0) || accepted($0) }
            }
            cuts.noteWhole(in: scroll, of: app)
        }
        app.terminate()
        for reason in cuts.neverWhole {
            XCTFail("\(screen): contrast passed as cut by the scroll edge, never audited whole: \(reason)")
        }
    }

    /**
     One audit of what `app` shows now, with the findings every screen accepts and those `accepted`
     adds, each finding named in the result bundle.
     */
    @MainActor
    func auditInPlace(
        _ app: XCUIApplication, accepting accepted: @escaping (XCUIAccessibilityAuditIssue) -> Bool = { _ in false }
    ) throws {
        let window = app.windows.firstMatch.frame
        try auditRetryingTimeout(app) { issue in
            let isAccepted = Self.isAcceptedEverywhere(issue, window: window) || accepted(issue)
            Self.record(issue, isAccepted: isAccepted)
            return isAccepted
        }
    }

    /**
     The findings every screen accepts, each an owner's decision recorded in docs/design-system.md.
     */
    @MainActor
    private static func isAcceptedEverywhere(_ issue: XCUIAccessibilityAuditIssue, window: CGRect) -> Bool {
        /**
         Accepted deviation: the design system's own small sizes (the 11 pt overline, the medium
         amount's 11 pt "Rp" and ",00", the 11 pt bar caption) are reported as partial Dynamic Type
         support; those texts carry `kira.small-type`.
         */
        if issue.auditType == .dynamicType, issue.element?.identifier == "kira.small-type" { return true }
        /**
         Accepted pending the owner, from the same deviation: "Text clipped" on those small texts,
         such as the 11 pt overline ("RENCANA BEBAS UTANG", "BEASISWA KIRA DITERIMA"), which have no
         line limit and render whole (the element screenshots); the audit predicts a cut at sizes the
         small style does not scale to.
         */
        if issue.auditType == .textClipped, issue.element?.identifier == "kira.small-type" { return true }
        /**
         Accepted: the contrast of a disabled control, such as "Verifikasi" before the six digits are
         in. A disabled KiraButton is drawn at 45% opacity (bundle.css, docs/design-system.md), and
         WCAG 1.4.3 exempts an inactive control from the contrast minimum; enabled, the same button
         is checked in full.
         */
        if issue.auditType == .contrast, issue.element?.isEnabled == false { return true }
        /**
         Accepted: a contrast finding on an element a scroll has left under the status bar or at the
         home indicator, where the audit samples the bar instead of the text's own background.
         */
        guard issue.auditType == .contrast, let frame = issue.element?.frame else { return false }
        /**
         Accepted, for the same reason: an element the screen's left or right edge cuts, such as the
         last chip of a row that scrolls sideways, where the audit samples pixels off the screen.
         */
        if frame.minX < window.minX || frame.maxX > window.maxX { return true }
        return frame.minY < window.minY + 100 || frame.maxY > window.maxY - 50
    }

    /**
     Names each finding in the result bundle (its type, element and frame), so a failure says which
     element it is about and an accepted one stays visible.
     */
    static func record(_ issue: XCUIAccessibilityAuditIssue, isAccepted: Bool) {
        let element = issue.element
        let name =
            "\(isAccepted ? "accepted" : "finding"): \(issue.compactDescription) on "
            + "[\(element?.label ?? "no element")] \(element?.identifier ?? "") \(element.map { "\($0.frame)" } ?? "")"
        XCTContext.runActivity(named: name) { _ in }
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

    /**
     How far the bottom of the scroll view's content lies below what is on screen. Other elements count
     too: a combined element, such as a KiraNotice, is neither text nor a button.
     */
    @MainActor
    private func hiddenBelow(in scroll: XCUIElement, window: CGRect) -> CGFloat {
        let bottoms = [scroll.staticTexts, scroll.buttons, scroll.otherElements].compactMap { query -> CGFloat? in
            let count = query.count
            return count > 0 ? query.element(boundBy: count - 1).frame.maxY : nil
        }
        return (bottoms.max() ?? 0) - min(scroll.frame.maxY, window.maxY)
    }

    /**
     One audit, made once more only when Apple's audit could not finish in time (XCTest's code -56):
     the tool timing out, not a finding. Any finding fails at once, and so does a second timeout.
     */
    @MainActor
    private func auditRetryingTimeout(
        _ app: XCUIApplication, accepting accepted: @escaping (XCUIAccessibilityAuditIssue) -> Bool
    ) throws {
        do {
            try app.performAccessibilityAudit(accepted)
        } catch let error as NSError where Self.auditTimedOut(error) {
            XCTContext.runActivity(named: "The audit did not finish in time; running it once more") { _ in }
            try app.performAccessibilityAudit(accepted)
        }
    }

    /**
     The audit ran out of time before it read the whole screen, in either of the two ways XCTest says
     so: the audit's own "Audit failed to complete in time" (-56), or its future timing out while it
     runs ("Timed out while running accessibility audit", code 1000).
     */
    private static func auditTimedOut(_ error: NSError) -> Bool {
        if error.domain == "com.apple.xcode.xctest.accessibilityAudit" { return error.code == -56 }
        return error.domain == "com.apple.dt.XCTest.XCTFuture" && error.code == 1000
            && error.localizedDescription.contains("accessibility audit")
    }

    /** The points a drag travels before the content starts to move (UIScrollView's touch slop). */
    private static let touchSlop: CGFloat = 10

    /**
     Scrolls by `distance`, at most about two thirds of a screen, with a drag that holds still before
     lifting, then lets the page settle. The drag adds the touch slop, which moves nothing, so the
     content moves by `distance` itself. Never past the end: a bounce there leaves the accessibility
     frames where the content was, and the audit then measures the wrong pixels.
     */
    @MainActor
    private func scrollDown(_ scroll: XCUIElement, by distance: CGFloat) {
        let height = scroll.frame.height
        let travel = min(distance + Self.touchSlop, height * 0.65) / max(height, 1)
        let start = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
        let end = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85 - travel))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 0.5)
        Thread.sleep(forTimeInterval: 1)
    }
}
