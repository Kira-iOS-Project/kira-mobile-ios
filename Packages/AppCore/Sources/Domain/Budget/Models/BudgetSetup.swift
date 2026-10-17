/**
 What Atur Budget (UNG-05, KIR-39) opens with, from `GET /budgets/current`: the income it shares
 out, the payday, each category's amount and its "Rata-rata 3 bulan", the open debts' monthly
 instalments, and the Dana Darurat goal's deposit (Pos Tujuan, set in Rencana, never here).
 */
package struct BudgetSetup: Equatable, Sendable {
    /** The health check's net income ("dari gaji"). */
    package let income: Int
    /** The payday the period follows. */
    package let payday: Payday
    /** Each category's amount; a category not listed has none. */
    package let allocations: [TransactionCategory: Int]
    /** Each category's average spend over the last three pay periods; missing is 0. */
    package let averages: [TransactionCategory: Int]
    /** The open debts' monthly instalments ("termasuk cicilan"). */
    package let instalments: Int
    /** The Dana Darurat goal's deposit per payday, nil without that goal. */
    package let goalDeposit: Int?

    /** A setup of these figures. */
    package init(
        income: Int, payday: Payday, allocations: [TransactionCategory: Int],
        averages: [TransactionCategory: Int] = [:], instalments: Int = 0, goalDeposit: Int? = nil
    ) {
        self.income = max(0, income)
        self.payday = payday
        self.allocations = allocations
        self.averages = averages
        self.instalments = max(0, instalments)
        self.goalDeposit = goalDeposit
    }

    /** The board's categories, then any other the person has an amount or a spend in, in a stable order. */
    package var categories: [TransactionCategory] {
        let used = Set(allocations.keys).union(averages.keys)
        let extra = TransactionCategory.allCases.filter { used.contains($0) && !Self.standard.contains($0) }
        return Self.standard + extra.filter { $0.type == .expense }
    }

    /** Makan & Minum, Transportasi, Belanja, Hiburan and Tagihan, as Atur Budget's board lists them. */
    package static let standard: [TransactionCategory] = [.food, .transport, .shopping, .entertainment, .bills]
}

/** What "Simpan Budget" sends (`PUT /budgets/current`): the payday and each category's amount. */
package struct BudgetPlan: Equatable, Sendable {
    /** The payday the period follows. */
    package let payday: Payday
    /** Each category's amount, every category once. */
    package let allocations: [TransactionCategory: Int]

    /** A plan of `allocations` on `payday`. */
    package init(payday: Payday, allocations: [TransactionCategory: Int]) {
        self.payday = payday
        self.allocations = allocations
    }
}
