import Testing

@testable import Domain

@Suite("CategoryKeywords")
struct CategoryKeywordsTests {
    @Test("every word belongs to one category, and every category's direction is its own")
    func table() {
        let count = CategoryKeywords.words.values.map(\.count).reduce(0, +)
        #expect(CategoryKeywords.index.count == count)
        #expect(CategoryKeywords.index["bensin"] == .transport)
    }

    @Test(
        "the first phrase or word names the category",
        arguments: [
            (["rumah", "sakit"], TransactionCategory.health), (["bayar", "kos"], .bills), (["grab", "ke", "kantor"], .transport),
            (["es", "kopi"], .coffee), (["makan", "bakso"], .food), (["netflix"], .entertainment),
        ])
    func category(words: [String], expected: TransactionCategory) {
        #expect(CategoryKeywords.category(of: words) == expected)
    }

    @Test("guesses: a keyword, income words, and the two 'other' categories")
    func guess() {
        #expect(CategoryKeywords.guess(["gaji"]) == (.salary, .income))
        #expect(CategoryKeywords.guess(["dapat", "kopi"]) == (.otherIncome, .income))
        #expect(CategoryKeywords.guess(["refund"]) == (.otherIncome, .income))
        #expect(CategoryKeywords.guess(["sesuatu"]) == (.otherExpense, .expense))
        #expect(CategoryKeywords.category(of: []) == nil)
    }
}
