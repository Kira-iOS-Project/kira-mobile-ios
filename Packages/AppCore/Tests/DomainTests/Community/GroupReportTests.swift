import Testing

@testable import Domain

@Suite("GroupReport")
struct GroupReportTests {
    @Test("nothing goes without a reason; a reason alone is enough, the story optional")
    func reason() {
        var report = GroupReport()
        #expect(!report.canSend && !report.requiresStory)
        report.reason = .scam
        #expect(report.canSend && report.trimmedStory == nil)
        report.story = "  ada yang minta transfer  "
        #expect(report.trimmedStory == "ada yang minta transfer")
    }

    @Test("Lainnya needs a story that is not blank")
    func other() {
        var report = GroupReport(reason: .other, story: "   ")
        #expect(report.requiresStory && !report.canSend)
        report.story = "Admin jualan data."
        #expect(report.canSend)
    }

    @Test("a story over 500 characters cannot be sent")
    func limit() {
        let report = GroupReport(reason: .inappropriate, story: String(repeating: "a", count: 501))
        #expect(!report.canSend)
        #expect(GroupReport(reason: .inappropriate, story: String(repeating: "a", count: 500)).canSend)
        #expect(GroupReportReason.allCases.map(\.rawValue) == [
            "default_invite", "guaranteed_profit", "scam", "data_or_jockey", "inappropriate", "other",
        ])
    }
}
