import Domain
import Testing

@Suite("BillEditDraft")
struct BillEditDraftTests {
    @Test("starts from a bill and normalizes editable values")
    func startsFromBill() throws {
        let draft = try #require(BillEditDraft(bill: bill()))
        #expect(draft.id == "bill-1")
        #expect(draft.amountText == "350.000")
        #expect(draft.update?.name == "Internet Rumah")
        #expect(draft.update?.amount == 350_000)
        #expect(draft.update?.nextDueDate == CalendarDay(year: 2026, month: 10, day: 22))
        #expect(draft.update?.category == .bills)
        #expect(draft.update?.repeatInterval == .monthly)
    }

    @Test("refuses an installment and server values the editor cannot represent")
    func unsupportedBill() {
        #expect(BillEditDraft(bill: bill(kind: .debtInstallment)) == nil)
        #expect(BillEditDraft(bill: bill(category: "unknown")) == nil)
        #expect(BillEditDraft(bill: bill(repeatInterval: "daily")) == nil)
    }

    @Test("requires a name, a positive amount and an expense category")
    func validation() throws {
        var draft = try #require(BillEditDraft(bill: bill()))
        draft.name = "  "
        #expect(draft.update == nil)
        draft.name = " Internet baru "
        draft.amountText = "0"
        #expect(draft.update == nil)
        draft.name = String(repeating: "x", count: 81)
        draft.amountText = "480000"
        #expect(draft.update == nil)
        draft.amountText = "Rp 480.000"
        draft.name = " Internet baru "
        draft.category = .salary
        #expect(draft.update == nil)
        draft.category = .bills
        #expect(draft.update?.name == "Internet baru")
        #expect(draft.update?.amount == 480_000)
    }

    private func bill(
        kind: RecurringBill.Kind = .bill, category: String = "bills", repeatInterval: String = "monthly"
    ) -> RecurringBill {
        RecurringBill(
            id: "bill-1", name: "Internet Rumah", amount: 350_000, category: category,
            nextDueDate: CalendarDay(year: 2026, month: 10, day: 22), repeatInterval: repeatInterval, kind: kind)
    }
}
