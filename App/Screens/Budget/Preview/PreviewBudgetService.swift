/** Budget values for previews and the debug screen audit, with no network requests. */
import Domain
import Features

nonisolated struct PreviewBudgetService: BudgetService {
    private let budget = Self.sample

    func currentBudget() async throws -> BudgetOverview { budget }

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
