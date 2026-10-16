import Foundation
import Testing

@testable import Domain

@Suite("ChatMessage")
struct ChatMessageTests {
    private func message(_ drafts: [DraftItem]?) -> ChatMessage {
        ChatMessage(id: "k1", sender: .kira, kind: .drafts, createdAt: .now, drafts: drafts)
    }

    private func draft(_ type: TransactionType, _ amount: Int) -> DraftItem {
        DraftItem(
            id: UUID().uuidString, type: type, name: "Kopi", amount: amount,
            category: type == .income ? .salary : .coffee, occurredAt: .now)
    }

    @Test("the drafts' total and their one side, or none when mixed or empty")
    func totals() {
        let expenses = message([draft(.expense, 25_000), draft(.expense, 5_000)])
        #expect(expenses.draftTotal == 30_000)
        #expect(expenses.draftType == .expense)
        #expect(message([draft(.income, 1)]).draftType == .income)
        #expect(message([draft(.income, 1), draft(.expense, 1)]).draftType == nil)
        #expect(message(nil).draftTotal == 0)
        #expect(message(nil).draftType == nil)
    }
}
