import APIClient
import Domain
import Testing

@testable import Features

private actor EditorBudgetService: BudgetService {
    private let savedBudget: BudgetOverview
    private let editContext: BudgetEditContext?
    private var results: [Result<BudgetOverview, AppProblem>]
    private(set) var submitted: [BudgetDraft] = []

    init(
        savedBudget: BudgetOverview, results: [Result<BudgetOverview, AppProblem>],
        editContext: BudgetEditContext? = nil
    ) {
        self.savedBudget = savedBudget
        self.results = results
        self.editContext = editContext
    }

    func currentBudget() async throws -> BudgetOverview { savedBudget }

    func currentBudgetEdit() async throws -> BudgetEditContext {
        editContext ?? BudgetEditContext(budget: savedBudget, averagePeriods: 0, averages: [])
    }

    func saveCurrentBudget(_ draft: BudgetDraft) async throws -> BudgetOverview {
        submitted.append(draft)
        if results.isEmpty { return savedBudget }
        return try results.removeFirst().get()
    }

    func saves() -> [BudgetDraft] { submitted }
}

private struct EditorUnexpectedError: Error {}

private struct BrokenEditorBudgetService: BudgetService {
    func currentBudget() async throws -> BudgetOverview { throw EditorUnexpectedError() }
    func saveCurrentBudget(_: BudgetDraft) async throws -> BudgetOverview { throw EditorUnexpectedError() }
}

@MainActor
@Suite("BudgetEditorModel")
struct BudgetEditorModelTests {
    private func overview() -> BudgetOverview {
        BudgetOverview(
            income: 1_000, payday: Payday(day: 31),
            period: PayPeriod(
                start: CalendarDay(year: 2026, month: 10, day: 31),
                end: CalendarDay(year: 2026, month: 11, day: 29), daysUntilPayday: 14),
            allocations: [BudgetAllocation(category: .food, amount: 700, spent: 400)])
    }

    @Test("edits rupiah strings and saves an overallocated draft")
    func editAndSave() async {
        let budget = overview()
        let savedBudget = BudgetOverview(
            income: budget.income, payday: .endOfMonth, period: budget.period,
            allocations: [
                BudgetAllocation(category: .food, amount: 1_200),
                BudgetAllocation(category: .transport, amount: 2),
                BudgetAllocation(category: .bills, amount: 0),
            ])
        let service = EditorBudgetService(savedBudget: savedBudget, results: [.success(savedBudget)])
        let model = BudgetEditorModel(budget: budget, service: service)
        #expect(model.payday == Payday(day: 31))
        #expect(model.incomeText == "1.000")
        model.setIncomeText("900")
        model.setIncomeText("")
        #expect(model.phase.value?.income == 0)
        model.setIncomeText("900")
        #expect(model.amountText(for: .food) == "700")
        model.setAmountText("1.200", for: .food)
        model.setAmountText("2abc", for: .transport)
        model.setAmountText("", for: .bills)
        model.setPayday(.endOfMonth)
        #expect(model.isOverallocated)
        #expect(model.amountText(for: .transport) == "2")
        #expect(model.amountText(for: .bills) == "")
        await model.save()
        if case .saved = model.saveState {} else { #expect(Bool(false)) }
        let saved = await service.saves().first
        #expect(saved?.income == 900 && saved?.allocated == 1_202)
        #expect(saved?.payday == .endOfMonth)
        #expect(model.phase.value?.payday == .endOfMonth)
        model.dismissResult()
        if case .idle = model.saveState {} else { #expect(Bool(false)) }
    }

    @Test("a failure keeps the draft and retry sends the same snapshot")
    func retry() async {
        let budget = overview()
        let problem = AppProblem(code: "INTERNAL_ERROR", requestId: "budget-save")
        let service = EditorBudgetService(savedBudget: budget, results: [.failure(problem), .success(budget)])
        let model = BudgetEditorModel(budget: budget, service: service)
        #expect(model.amountText(for: .otherExpense).isEmpty)
        model.setAmountText("900", for: .food)
        await model.save()
        if case .failed(let shown) = model.saveState { #expect(shown == problem) } else { #expect(Bool(false)) }
        #expect(model.amountText(for: .food) == "900")
        model.setAmountText("500", for: .food)
        await model.retry()
        #expect(await service.saves().map(\.allocations.first?.amount) == [900, 900])
        #expect(await service.saves().map(\.income) == [1_000, 1_000])
        if case .saved = model.saveState {} else { #expect(Bool(false)) }
    }

    @Test("loads category averages from complete prior periods")
    func averages() async {
        let budget = overview()
        let context = BudgetEditContext(
            budget: budget, averagePeriods: 3,
            averages: [BudgetCategoryAverage(category: .food, amount: 525)])
        let model = BudgetEditorModel(
            budget: budget, service: EditorBudgetService(savedBudget: budget, results: [], editContext: context))
        await model.loadAverages()
        #expect(model.averagePeriods == 3)
        #expect(model.averageAmount(for: .food) == 525)
        #expect(model.averageAmount(for: .transport) == nil)
    }

    @Test("an unexpected save error becomes a generic problem and retry without failure is ignored")
    func unexpectedFailure() async {
        let empty = BudgetEditorModel(budget: nil, service: BrokenEditorBudgetService())
        #expect(empty.payday == Payday(day: Payday.defaultDay))
        #expect(!empty.isOverallocated)
        empty.setIncomeText("1.000")
        empty.setAmountText("500", for: .food)
        empty.setPayday(.endOfMonth)
        await empty.save()
        if case .empty = empty.phase {} else { #expect(Bool(false)) }

        let model = BudgetEditorModel(budget: overview(), service: BrokenEditorBudgetService())
        await model.loadAverages()
        #expect(model.averagePeriods == 0)
        #expect(model.averageAmount(for: .food) == nil)
        await model.retry()
        await model.save()
        if case .failed(let shown) = model.saveState { #expect(shown == AppProblem()) } else { #expect(Bool(false)) }
        model.dismissResult()
        await model.retry()
        if case .idle = model.saveState {} else { #expect(Bool(false)) }
    }
}
