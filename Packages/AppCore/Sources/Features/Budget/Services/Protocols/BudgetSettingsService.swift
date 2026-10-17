import Domain

/** Atur Budget's calls: what the screen opens with (`GET /budgets/current`) and "Simpan Budget" (`PUT`). */
package protocol BudgetSettingsService: Sendable {
    /** The income, payday, amounts, averages, instalments and goal deposit Atur Budget shows. */
    func budgetSetup() async throws -> BudgetSetup

    /** Saves the payday and every category's amount. */
    func saveBudget(_ plan: BudgetPlan) async throws
}
