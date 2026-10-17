import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("BillCreateModel loading")
struct BillCreateModelLoadTests {
    @Test("uses the current WIB day when no date provider is injected")
    func defaultToday() {
        let model = BillCreateModel(service: FakeBillsService())
        #expect(model.minimumDueDate == CalendarDay(Date()).start)
    }

    @Test("loads the owner's debt choices once and exposes only expense categories")
    func loadedAccounts() async {
        let day = CalendarDay(year: 2026, month: 10, day: 17)
        let account = BillDebtAccount(id: "debt-1", name: "Paylater")
        let service = FakeBillsService(debtAccounts: .success([account]))
        let model = BillCreateModel(service: service, today: { day })

        await model.load()
        await model.load()

        #expect(model.phase.value?.savedBill == nil)
        #expect(model.debtAccounts == [account] && !model.isLoadingAccounts)
        #expect(model.minimumDueDate == day.start && model.savedBill == nil)
        #expect(model.categories == TransactionCategory.allCases.filter { $0.type == .expense })
        #expect(await service.accountCalls() == 1)
        #expect(!model.canSave)
    }

    @Test("shows an empty choice state and can still save a regular bill")
    func emptyAccounts() async {
        let day = CalendarDay(year: 2026, month: 10, day: 17)
        let model = BillCreateModel(service: FakeBillsService(), today: { day })
        await model.load()

        guard case .empty = model.phase else {
            Issue.record("expected an empty debt-account choice phase")
            return
        }
        model.name = "Listrik"
        model.amountText = "150.000"
        #expect(model.canSave)
    }

    @Test("preserves a load problem and offers a retry")
    func accountFailure() async {
        let problem = BillsFixtures.problem("HTTP_ERROR")
        let service = FakeBillsService(debtAccounts: .failure(problem))
        let model = BillCreateModel(service: service)

        await model.load()
        guard case .failed(let failure) = model.phase else {
            Issue.record("expected the account problem")
            return
        }
        #expect(failure == problem && model.debtAccountsProblem == problem)
        await model.retryDebtAccounts()
        #expect(await service.accountCalls() == 2)
        #expect(model.debtAccountsProblem == problem)
    }
}
