import Testing

@testable import Domain

@Suite("PlanTerms")
struct PlanTermsTests {
    private func terms(monthly: Int, yearly: Int) -> PlanTerms {
        PlanTerms(
            id: .young, monthlyPrice: monthly, yearlyPrice: yearly, aiMessages: 100, receipts: 40)
    }

    @Test("prices each period")
    func price() {
        let young = terms(monthly: 15_000, yearly: 150_000)
        #expect(young.price(for: .monthly) == 15_000)
        #expect(young.price(for: .yearly) == 150_000)
    }

    @Test("saves twelve monthly payments less the yearly price, never below zero")
    func saving() {
        #expect(terms(monthly: 15_000, yearly: 150_000).yearlySaving == 30_000)
        #expect(terms(monthly: 29_000, yearly: 290_000).yearlySaving == 58_000)
        #expect(terms(monthly: 10_000, yearly: 130_000).yearlySaving == 0)
    }

    @Test("counts the monthly payments a year's price equals, rounded up")
    func paidMonths() {
        #expect(terms(monthly: 29_000, yearly: 290_000).yearlyPaidMonths == 10)
        #expect(terms(monthly: 15_000, yearly: 151_000).yearlyPaidMonths == 11)
        #expect(terms(monthly: 0, yearly: 0).yearlyPaidMonths == 0)
    }
}
