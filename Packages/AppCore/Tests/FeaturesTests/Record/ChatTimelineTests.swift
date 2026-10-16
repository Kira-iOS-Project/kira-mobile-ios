import Domain
import Foundation
import Testing

@testable import Features

@Suite("ChatTimeline")
struct ChatTimelineTests {
    private let morning = Fixtures.noon.addingTimeInterval(-(4 * 3_600 + 29 * 60))

    @Test("the board: two stretches, each opened by its time, every kind in its row")
    func board() {
        let messages = [
            Fixtures.person("m1", "bensin 30rb", at: morning),
            Fixtures.drafts(
                "k1", replyTo: "m1", items: [Fixtures.draft("d1", name: "Bensin", amount: 30_000)], status: .committed,
                batchId: "b1", at: morning),
            Fixtures.person("m2", "makan siang 25rb"),
            Fixtures.drafts("k2", replyTo: "m2", items: [Fixtures.draft("d2", name: "Makan Siang", amount: 25_000)]),
            Fixtures.kira("k3", kind: .remaining),
            Fixtures.drafts("k4", replyTo: "gone", items: [], status: .discarded),
            Fixtures.kira("k5", kind: .manualSaved),
            Fixtures.kira("k6", kind: .noDrafts),
            Fixtures.person("m3", "struk", at: Fixtures.noon.addingTimeInterval(86_400), kind: .personReceipt),
        ]
        let rows = ChatTimeline.rows(of: messages, undoable: ["k1"])
        #expect(
            rows.map(\.id) == [
                "separator-m1", "m1", "k1", "separator-m2", "m2", "k2", "k3", "k4", "k5", "k6", "separator-m3", "m3",
            ])
        #expect(rows[0] == .separator(id: "separator-m1", date: morning))
        #expect(rows[2] == .saved(messages[1], source: messages[0], canUndo: true))
        #expect(rows[5] == .drafts(messages[3], source: messages[2]))
        #expect(rows[7] == .discarded(messages[5]))
        #expect(rows[6] == .remaining(messages[4]))
        #expect(rows[8] == .manualSaved(messages[6]))
        #expect(rows[9] == .noDrafts(messages[7]))
    }

    @Test("a draft message without a status waits like a pending one")
    func noStatus() {
        let message = ChatMessage(id: "k", sender: .kira, kind: .drafts, createdAt: Fixtures.noon)
        #expect(ChatTimeline.rows(of: [message], undoable: []).last == .drafts(message, source: nil))
    }
}
