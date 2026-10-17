/** Budget values for previews and the debug screen audit, with no network requests. */
import Domain
import Features

nonisolated struct PreviewBudgetService: BudgetService {
    private let budget = Self.sample

    func currentBudget() async throws -> BudgetOverview { budget }

    func currentBudgetEdit() async throws -> BudgetEditContext {
        BudgetEditContext(
            budget: budget, averagePeriods: 3,
            averages: [
                BudgetCategoryAverage(category: .food, amount: 1_100_000),
                BudgetCategoryAverage(category: .transport, amount: 250_000),
            ])
    }

    func saveCurrentBudget(_ draft: BudgetDraft) async throws -> BudgetOverview {
        BudgetOverview(
            income: draft.income, remaining: budget.remaining, goalPosts: budget.goalPosts,
            payday: draft.payday, period: budget.period,
            allocations: draft.allocations, isConfigured: true)
    }

    private static let sample = BudgetOverview(
        income: 7_500_000, payday: Payday(day: 25),
        period: PayPeriod(
            start: CalendarDay(year: 2026, month: 9, day: 25),
            end: CalendarDay(year: 2026, month: 10, day: 24), daysUntilPayday: 8),
        allocations: [
            BudgetAllocation(category: .food, amount: 1_500_000, spent: 1_380_000),
            BudgetAllocation(category: .transport, amount: 650_000, spent: 280_000),
            BudgetAllocation(category: .bills, amount: 900_000, spent: 450_000),
            BudgetAllocation(category: .shopping, amount: 1_000_000, spent: 320_000),
            BudgetAllocation(category: .savingsDeposit, amount: 1_250_000, spent: 0),
        ])
}

#if DEBUG
    import SwiftUI

    #Preview("Budget") {
        NavigationStack { BudgetScreen(service: PreviewBudgetService()) }
    }
#endif
