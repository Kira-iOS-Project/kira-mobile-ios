import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("BillCreateModel validation")
struct BillCreateModelValidationTests {
    @Test("shows required, too-long, nonpositive amount, past-date and missing-account errors")
    func invalidDraft() async {
        let today = CalendarDay(year: 2026, month: 10, day: 17)
        let account = BillDebtAccount(id: "debt-1", name: "Paylater")
        let model = BillCreateModel(
            service: FakeBillsService(debtAccounts: .success([account])), today: { today })
        await model.load()
        model.dueDate = today.adding(days: -1)
        await model.save()
        #expect(model.showsFieldErrors && !model.canSave)
        #expect(model.nameError != nil && model.amountError != nil && model.dueDateError != nil)

        model.name = String(repeating: "x", count: 81)
        model.amountText = "0"
        model.isDebtInstallment = true
        await model.save()
        #expect(model.nameError != nil && model.amountError != nil && model.debtAccountError != nil)
        #expect(model.dueDateError != nil)
        model.linkedDebtAccountID = "debt-2"
        #expect(model.debtAccountError != nil)
        model.linkedDebtAccountID = account.id
        #expect(model.debtAccountError == nil)
    }

    @Test("converts the selected date to WIB and accepts a valid form")
    func selectedDate() async {
        let today = CalendarDay(year: 2026, month: 10, day: 17)
        let model = BillCreateModel(service: FakeBillsService(), today: { today })
        await model.load()
        model.selectDueDate(today.adding(days: 4).start)
        model.name = "  Internet Rumah  "
        model.amountText = "125.000"
        #expect(model.dueDate == today.adding(days: 4))
        #expect(model.nameError == nil && model.amountError == nil && model.dueDateError == nil)
        #expect(model.canSave)
    }

    @Test("clears the linked account when the debt installment toggle is turned off")
    func debtToggle() async {
        let account = BillDebtAccount(id: "debt-1", name: "Paylater")
        let model = BillCreateModel(
            service: FakeBillsService(debtAccounts: .success([account])),
            today: { CalendarDay(year: 2026, month: 10, day: 17) })
        await model.load()
        model.isDebtInstallment = true
        model.linkedDebtAccountID = account.id
        model.name = "Tagihan Internet"
        model.amountText = "125.000"
        #expect(model.debtAccountError == nil && model.canSave)
        model.isDebtInstallment = false
        #expect(model.linkedDebtAccountID == nil)
    }
}
