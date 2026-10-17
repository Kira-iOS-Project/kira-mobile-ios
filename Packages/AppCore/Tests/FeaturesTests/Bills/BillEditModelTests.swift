import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("BillEditModel")
struct BillEditModelTests {
    @Test("loads a bill into a valid draft and saves the updated schedule")
    func loadAndSave() async throws {
        let service = FakeBillEditService()
        let model = BillEditModel(id: "bill-1", service: service)
        await model.load()
        #expect(model.phase.value?.id == "bill-1")
        #expect(model.canSave)
        model.draft?.name = " Internet Baru "
        model.draft?.amountText = "450000"
        await model.save()
        #expect(model.hasSaved)
        #expect(model.saveProblem == nil)
        #expect(model.phase.value?.name == "Internet Rumah")
        let calls = await service.calls()
        #expect(calls.loads == 1 && calls.updates.count == 1)
        #expect(calls.updates[0].0 == "bill-1")
        #expect(calls.updates[0].1.name == "Internet Baru")
        #expect(calls.updates[0].1.amount == 450_000)
    }

    @Test("keeps the draft on save failure and sends it again on retry")
    func retriesSave() async throws {
        let service = FakeBillEditService(
            update: .failure(BillEditFixtures.problem))
        let model = BillEditModel(id: "bill-1", service: service)
        await model.load()
        model.draft?.name = "Internet diubah"
        let draft = try #require(model.draft)
        await model.save()
        #expect(model.saveProblem == BillEditFixtures.problem)
        #expect(model.draft == draft)
        #expect(!model.hasSaved && !model.isSaving)
        await model.save()
        #expect(await service.calls().updates.count == 2)
        #expect(await service.calls().updates.allSatisfy { $0.1 == draft.update })
        #expect(billEditProblem(BillEditFixtures.problem) == BillEditFixtures.problem)
        struct Offline: Error {}
        #expect(billEditProblem(Offline()) == AppProblem())
    }

    @Test("shows empty when the selected schedule is a debt installment")
    func unsupportedSchedule() async {
        let installment = RecurringBill(
            id: "debt-1", name: "Cicilan", amount: 100, category: "paylater_instalment",
            nextDueDate: CalendarDay(year: 2026, month: 10, day: 22), repeatInterval: "monthly", kind: .debtInstallment)
        let service = FakeBillEditService(bill: .success(installment))
        let model = BillEditModel(id: installment.id, service: service)
        await model.load()
        guard case .empty = model.phase else {
            Issue.record("expected unsupported schedule to be empty")
            return
        }
        #expect(model.draft == nil && !model.canSave)
        await model.save()
        #expect(await service.calls().updates.isEmpty)
    }

    @Test("maps load errors and refuses invalid form values")
    func loadFailureAndInvalidDraft() async throws {
        let service = FakeBillEditService(bill: .failure(BillEditFixtures.problem))
        let model = BillEditModel(id: "bill-1", service: service)
        await model.load()
        guard case .failed(let problem) = model.phase else {
            Issue.record("expected failure")
            return
        }
        #expect(problem == BillEditFixtures.problem)
        await model.save()
        #expect(!model.canSave && !model.hasSaved)
        #expect(model.showsFieldErrors && model.nameError == nil && model.amountError == nil)

        let ready = BillEditModel(id: "bill-1", service: FakeBillEditService())
        await ready.load()
        #expect(ready.nameError == nil && ready.amountError == nil)
        #expect(ready.categories.allSatisfy { $0.type == .expense })
        ready.draft?.name = " "
        ready.draft?.amountText = "0"
        await ready.save()
        #expect(!ready.canSave && ready.saveProblem == nil)
        #expect(ready.nameError != nil && ready.amountError != nil)
        ready.draft?.name = String(repeating: "x", count: 81)
        ready.draft?.amountText = "1000"
        #expect(ready.nameError != nil && ready.amountError == nil)
        ready.draft?.name = "Nama valid"
        #expect(ready.nameError == nil)
        #expect(await service.calls().updates.isEmpty)
    }

    @Test("maps an unexpected load error to the generic problem")
    func genericFailure() async {
        struct Offline: Error {}
        let model = BillEditModel(id: "bill-1", service: FakeBillEditService(bill: .failure(Offline())))
        await model.load()
        guard case .failed(let problem) = model.phase else {
            Issue.record("expected generic failure")
            return
        }
        #expect(problem == AppProblem())
    }
}
