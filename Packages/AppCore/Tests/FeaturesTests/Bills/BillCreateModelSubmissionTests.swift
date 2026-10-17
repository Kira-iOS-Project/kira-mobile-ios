import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("BillCreateModel submission")
struct BillCreateModelSubmissionTests {
    @Test("saves a normal bill and keeps the result only after success")
    func success() async throws {
        let today = CalendarDay(year: 2026, month: 10, day: 17)
        let service = FakeBillsService(created: .success(BillsFixtures.bill))
        let model = BillCreateModel(service: service, today: { today })
        await model.load()
        model.name = " Internet Rumah "
        model.amountText = "350.000"
        model.dueDate = today.adding(days: 3)

        await model.save()

        #expect(model.savedBill == BillsFixtures.bill)
        #expect(model.nameError == nil)
        #expect(try #require(model.phase.value?.savedBill) == BillsFixtures.bill)
        let request = try #require(await service.submissions().first)
        #expect(request.name == "Internet Rumah" && request.amount == 350_000)
        #expect(request.linkedDebtAccountID == nil && request.nextDueDate == today.adding(days: 3))
    }

    @Test("keeps one idempotency key across retries and creates a new key after the draft changes")
    func retry() async throws {
        let today = CalendarDay(year: 2026, month: 10, day: 17)
        let problem = BillsFixtures.problem("HTTP_ERROR")
        let account = BillDebtAccount(id: "debt-1", name: "Paylater")
        let service = FakeBillsService(
            debtAccounts: .success([account]), created: .failure(problem))
        let model = BillCreateModel(service: service, today: { today })
        await model.load()
        model.name = "Cicilan"
        model.amountText = "125000"
        model.isDebtInstallment = true
        model.linkedDebtAccountID = account.id

        await model.save()
        let first = try #require(await service.submissions().first)
        #expect(model.savedBill == nil && model.saveProblem == problem)
        await model.save()
        let second = try #require(await service.submissions().last)
        #expect(first.clientID == second.clientID && first.linkedDebtAccountID == account.id)
        model.amountText = "130000"
        await model.save()
        let third = try #require(await service.submissions().last)
        #expect(third.clientID != second.clientID && third.amount == 130_000)

        model.resetDraft()
        #expect(model.name.isEmpty && model.amountText.isEmpty && !model.isDebtInstallment)
        #expect(model.linkedDebtAccountID == nil && !model.showsFieldErrors && model.saveProblem == nil)
        #expect(model.dueDate == today && model.phase.value?.savedBill == nil)
        #expect(model.debtAccounts == [account])
        guard case .loaded = model.phase else {
            Issue.record("expected reset to keep the loaded debt choices")
            return
        }
    }
}
