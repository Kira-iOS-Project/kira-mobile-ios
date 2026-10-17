import Domain
import Testing

@Suite("BillDraft")
struct BillDraftTests {
    @Test("repeats and categories carry the API's values")
    func rawValues() {
        #expect(BillRepeat.allCases.map(\.rawValue) == ["once", "monthly", "yearly"])
        #expect(BillCategory.allCases.map(\.rawValue) == ["bills", "entertainment", "health", "other_expense"])
    }

    @Test("a draft is a plain bill unless it names a debt account")
    func draft() {
        let day = CalendarDay(year: 2026, month: 10, day: 22)
        let plain = BillDraft(name: "Internet Rumah", amount: 350_000, category: .bills, repeats: .monthly, dueOn: day)
        #expect(plain.debtId == nil && plain.dueOn == day)
        var linked = plain
        linked.debtId = "debt-1"
        #expect(linked != plain)
    }
}
