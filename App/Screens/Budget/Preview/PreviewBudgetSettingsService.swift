/**
 Atur Budget's figures as its board draws them (AturBudget): Rp7.500.000,00 income, payday the 25th,
 five categories with their averages, Rp1.350.000,00 of instalments and the Dana Darurat deposit.
 `saves: false` fails every save, for Belum Berhasil Menyimpan.
 */
import APIClient
import Domain
import Features

nonisolated struct PreviewBudgetSettingsService: BudgetSettingsService {
    var saves = true

    func budgetSetup() throws -> BudgetSetup { Self.sample }

    func saveBudget(_: BudgetPlan) throws {
        if !saves { throw AppProblem.connectionLost }
    }

    static let sample = BudgetSetup(
        income: 7_500_000, payday: Payday(day: 25),
        allocations: [
            .food: 1_800_000, .transport: 900_000, .shopping: 600_000, .entertainment: 400_000, .bills: 850_000,
        ],
        averages: [
            .food: 1_720_000, .transport: 860_000, .shopping: 640_000, .entertainment: 380_000, .bills: 850_000,
        ],
        instalments: 1_350_000, goalDeposit: 650_000)
}
