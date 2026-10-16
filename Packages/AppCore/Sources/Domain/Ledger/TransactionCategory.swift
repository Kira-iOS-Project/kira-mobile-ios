/**
 A transaction's category, with the backend's ids (`EXPENSE_CATEGORY`, `INCOME_CATEGORY` in
 kira-backend `src/lib/constants/money.ts`). The app draws each with a design-system tile.
 */
package enum TransactionCategory: String, CaseIterable, Codable, Sendable {
    case food, coffee, transport, shopping, bills
    case paylaterInstalment = "paylater_instalment"
    case savingsDeposit = "savings_deposit"
    case insurance, entertainment, health, education, household
    case otherExpense = "other_expense"
    case salary, bonus, business
    case otherIncome = "other_income"

    /** The direction a category belongs to. */
    package var type: TransactionType {
        switch self {
        case .salary, .bonus, .business, .otherIncome: .income
        default: .expense
        }
    }
}
