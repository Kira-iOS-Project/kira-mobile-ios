import Testing

@testable import Domain

@Suite("TransactionCategory")
struct TransactionCategoryTests {
    @Test("income categories are income, the rest expenses", arguments: TransactionCategory.allCases)
    func direction(category: TransactionCategory) {
        let income: Set<TransactionCategory> = [.salary, .bonus, .business, .otherIncome]
        #expect(category.type == (income.contains(category) ? .income : .expense))
    }
}
