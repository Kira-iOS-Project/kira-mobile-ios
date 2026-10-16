import Foundation
import Testing

@testable import Domain

@Suite("RecordProfile")
struct RecordProfileTests {
    private func profile(_ name: String, voiceLimit: Int) -> RecordProfile {
        let none = UsageCounter(used: 0, limit: 0)
        let usage = Usage(
            aiMessages: none, receipts: none, voiceSeconds: UsageCounter(used: 0, limit: voiceLimit), resetsOn: .now)
        return RecordProfile(
            displayName: name, plan: .plus, usage: usage, periodStart: .now, periodEnd: .now, aiEnabled: true,
            lastExpenseCategory: nil, lastIncomeCategory: nil)
    }

    @Test("the initial is the name's first letter in capitals, empty without a name; voice needs a limit")
    func initial() {
        #expect(profile("dinda", voiceLimit: 10_800).initial == "D")
        #expect(profile("", voiceLimit: 0).initial.isEmpty)
        #expect(profile("dinda", voiceLimit: 10_800).hasVoice)
        #expect(!profile("dinda", voiceLimit: 0).hasVoice)
    }

    @Test("a counter's remaining never goes below zero")
    func counter() {
        #expect(UsageCounter(used: 31, limit: 30).remaining == 0)
        #expect(UsageCounter(used: 4, limit: 10).remaining == 6)
        #expect(UsageCounter(used: 30, limit: 30).isExhausted)
    }
}
