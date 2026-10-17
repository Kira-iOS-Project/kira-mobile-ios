import APIClient
import Domain
import Testing

@testable import Features

private struct UnexpectedBudgetError: Error {}

private struct FakeBudgetService: BudgetService {
    let current: Result<BudgetOverview, AppProblem>
    var failsUnexpectedly = false

    func currentBudget() throws -> BudgetOverview {
        if failsUnexpectedly { throw UnexpectedBudgetError() }
        return try current.get()
    }
}

@MainActor
@Suite("BudgetModel")
struct BudgetModelTests {
    private func overview() -> BudgetOverview {
        BudgetOverview(
            income: 4_000_000,
            period: PayPeriod(
                start: CalendarDay(year: 2026, month: 10, day: 25),
                end: CalendarDay(year: 2026, month: 11, day: 24), daysUntilPayday: 9),
            allocations: [BudgetAllocation(category: .food, amount: 1_000_000, spent: 920_000)])
    }

    @Test("loads the server budget and reports known and unexpected failures")
    func load() async {
        let model = BudgetModel(service: FakeBudgetService(current: .success(overview())))
        #expect(model.phase.value == nil)
        await model.load()
        #expect(model.phase.value?.period.start == overview().period.start)

        let problem = AppProblem(code: "INTERNAL_ERROR", requestId: "budget-load")
        let failing = BudgetModel(service: FakeBudgetService(current: .failure(problem)))
        await failing.load()
        if case .failed(let shown) = failing.phase { #expect(shown == problem) } else { #expect(Bool(false)) }

        let broken = BudgetModel(service: FakeBudgetService(current: .failure(AppProblem()), failsUnexpectedly: true))
        await broken.load()
        if case .failed(let shown) = broken.phase { #expect(shown == AppProblem()) } else { #expect(Bool(false)) }
    }

    @Test("a budget not configured yet is empty, not loaded")
    func notConfigured() async {
        let blank = BudgetOverview(
            income: 0, period: overview().period, allocations: [], isConfigured: false)
        let model = BudgetModel(service: FakeBudgetService(current: .success(blank)))
        await model.load()
        if case .empty = model.phase {} else { Issue.record("expected empty") }
    }
}
