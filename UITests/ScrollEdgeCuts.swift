/**
 The contrast findings `auditScreen` accepts on elements the scroll view's own top or bottom edge
 cuts, such as Laporkan Grup's privacy note half under the sheet's scroll edge above Kirim Laporan:
 there the audit samples what lies past the edge, not the text's own background. The acceptance is
 checked, never assumed: each cut element must also be seen whole inside the scroll view after some
 pass (audited uncut there), or the screen's test fails.
 */
import XCTest

@MainActor
final class ScrollEdgeCuts {
    private let clip: CGRect
    /** The elements accepted as cut: label (or identifier) to the frame each was cut at. */
    private var cut: [String: CGRect] = [:]
    /** The labelled elements seen whole inside the scroll view after a pass. */
    private var whole: Set<String> = []
    /** Each cut element's frame when last looked up, for the failure's message. */
    private var lastSeen: [String: CGRect] = [:]
    /** How many passes the scroll view's snapshot could not be taken. */
    private var snapshotFailures = 0

    /** Cuts by the edges of `clip`, the scroll view's frame. */
    init(clip: CGRect) {
        self.clip = clip
    }

    /** Whether `issue` is a contrast finding on a named element the edge cuts; it is then recorded. */
    func accepts(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        guard issue.auditType == .contrast, let element = issue.element else { return false }
        let frame = element.frame
        let name = element.label.isEmpty ? element.identifier : element.label
        guard !name.isEmpty, frame.intersects(clip), frame.minY < clip.minY || frame.maxY > clip.maxY else {
            return false
        }
        cut[name] = frame
        return true
    }

    /**
     After a pass: notes the elements `scroll` shows whole now, as that pass audited them. Each cut
     element is looked up in `app` by its name; the snapshot adds those whole before their cut.
     */
    func noteWhole(in scroll: XCUIElement, of app: XCUIApplication) {
        for name in cut.keys where !whole.contains(name) {
            let named = NSPredicate(format: "label == %@ OR identifier == %@", name, name)
            let element = app.descendants(matching: .any).matching(named).firstMatch
            guard element.exists else { continue }
            lastSeen[name] = element.frame
            if clip.contains(element.frame) { whole.insert(name) }
        }
        guard scroll.exists, let root = try? scroll.snapshot() else {
            snapshotFailures += 1
            return
        }
        var stack: [any XCUIElementSnapshot] = [root]
        while let node = stack.popLast() {
            let name = node.label.isEmpty ? node.identifier : node.label
            if !name.isEmpty, clip.contains(node.frame) { whole.insert(name) }
            stack.append(contentsOf: node.children)
        }
    }

    /** Why each element accepted as cut was never seen whole: its frames, cut and last seen. */
    var neverWhole: [String] {
        cut.filter { !whole.contains($0.key) }.map { name, frame in
            let last = lastSeen[name].map { "\($0)" } ?? "not found"
            return "[\(name)] cut at \(frame), last seen at \(last) in \(clip), \(snapshotFailures) snapshot(s) failed"
        }
    }
}
