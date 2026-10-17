/** Budget values for previews and the debug screen audit, with no network requests. */
import Domain
import Features

nonisolated struct PreviewBudgetService: BudgetService {
    private let budget = Self.sample

    func currentBudget() throws -> BudgetOverview { budget }

    /** Board Budget: Rp1.840.000,00 left of Rp7.500.000,00, ten days to payday, Dana Darurat set aside. */
    private static let sample = BudgetOverview(
        income: 7_500_000, remaining: 1_840_000,
        goalPosts: [
            BudgetGoalPost(
                category: "emergency_fund", name: "Dana Darurat", currentAmount: 650_000, targetAmount: 650_000,
                milestones: [])
        ],
        payday: Payday(day: 25),
        period: PayPeriod(
            start: CalendarDay(year: 2026, month: 9, day: 25),
            end: CalendarDay(year: 2026, month: 10, day: 24), daysUntilPayday: 10),
        allocations: [
            BudgetAllocation(category: .food, amount: 1_800_000, spent: 1_380_000),
            BudgetAllocation(category: .transport, amount: 900_000, spent: 620_000),
            BudgetAllocation(category: .shopping, amount: 600_000, spent: 540_000),
            BudgetAllocation(category: .entertainment, amount: 400_000, spent: 310_000),
            BudgetAllocation(category: .bills, amount: 850_000, spent: 850_000),
        ])
}

#if DEBUG
    import SwiftUI

    #Preview("Budget") {
        NavigationStack { BudgetScreen(service: PreviewBudgetService()) { _ in } }
    }
#endif
