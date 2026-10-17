import Domain
import Testing

@testable import Features

private actor PausedBudgetService: BudgetService {
    private let budget: BudgetOverview
    private var saveContinuation: CheckedContinuation<BudgetOverview, Error>?
    private var startWaiters: [CheckedContinuation<Void, Never>] = []

    init(budget: BudgetOverview) { self.budget = budget }
    func currentBudget() async throws -> BudgetOverview { budget }

    func saveCurrentBudget(_: BudgetDraft) async throws -> BudgetOverview {
        try await withCheckedThrowingContinuation { continuation in
            saveContinuation = continuation
            for waiter in startWaiters { waiter.resume() }
            startWaiters = []
        }
    }

    func waitUntilSaving() async {
        if saveContinuation != nil { return }
        await withCheckedContinuation { startWaiters.append($0) }
    }

    func finishSave() {
        saveContinuation?.resume(returning: budget)
        saveContinuation = nil
    }
}

@MainActor
@Suite("Budget editor saves")
struct BudgetEditorSavingTests {
    @Test("ignores a second save and retry while the first save is in flight")
    func savingGuard() async {
        let budget = BudgetOverview(
            income: 1_000, payday: Payday(day: 25),
            period: PayPeriod(
                start: CalendarDay(year: 2026, month: 9, day: 25),
                end: CalendarDay(year: 2026, month: 10, day: 24), daysUntilPayday: 1),
            allocations: [])
        let service = PausedBudgetService(budget: budget)
        let model = BudgetEditorModel(budget: budget, service: service)
        let firstSave = Task { await model.save() }
        await service.waitUntilSaving()
        if case .saving = model.saveState {} else { #expect(Bool(false)) }

        await model.save()
        await model.retry()
        await service.finishSave()
        await firstSave.value
        if case .saved = model.saveState {} else { #expect(Bool(false)) }
    }
}
