/**
 A transaction's category, with the backend's ids (`EXPENSE_CATEGORY`, `INCOME_CATEGORY` in
 kira-backend `src/lib/constants/money.ts`). The app draws each with a design-system tile.
 */
package enum TransactionCategory: String, CaseIterable, Codable, Sendable {
    /** Makan & Minum. */
    case food
    /** Kopi. */
    case coffee
    /** Transportasi. */
    case transport
    /** Belanja. */
    case shopping
    /** Tagihan. */
    case bills
    /** Paylater: an instalment paid. */
    case paylaterInstalment = "paylater_instalment"
    /** Tabungan: money set aside. */
    case savingsDeposit = "savings_deposit"
    /** Proteksi: an insurance premium. */
    case insurance
    /** Hiburan. */
    case entertainment
    /** Kesehatan. */
    case health
    /** Pendidikan. */
    case education
    /** Rumah. */
    case household
    /** Lainnya, for an expense. */
    case otherExpense = "other_expense"
    /** Gaji. */
    case salary
    /** Bonus. */
    case bonus
    /** Usaha. */
    case business
    /** Lainnya, for income. */
    case otherIncome = "other_income"

    /** The direction a category belongs to. */
    package var type: TransactionType {
        switch self {
        case .salary, .bonus, .business, .otherIncome: .income
        default: .expense
        }
    }
}
