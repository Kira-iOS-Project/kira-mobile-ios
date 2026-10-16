/**
 One plan's prices and monthly quotas, as `GET /plans` sends them (the backend's `PLAN_TERMS`).
 Prices are whole rupiah. The yearly saving is worked out here from the two prices, so the screen
 never shows a struck-through price, only what twelve monthly payments would cost more.
 */
package struct PlanTerms: Hashable, Sendable {
    /** Which plan. */
    package let id: PlanID
    /** The price of one month. */
    package let monthlyPrice: Int
    /** The price of one year. */
    package let yearlyPrice: Int
    /** Chat messages Kira reads a month. */
    package let aiMessages: Int
    /** Receipts Kira reads a month. */
    package let receipts: Int

    /** The terms as the API sends them. */
    package init(id: PlanID, monthlyPrice: Int, yearlyPrice: Int, aiMessages: Int, receipts: Int) {
        self.id = id
        self.monthlyPrice = monthlyPrice
        self.yearlyPrice = yearlyPrice
        self.aiMessages = aiMessages
        self.receipts = receipts
    }

    /** The price of one period. */
    package func price(for period: BillingPeriod) -> Int {
        switch period {
        case .monthly: monthlyPrice
        case .yearly: yearlyPrice
        }
    }

    /** What a year costs less than twelve monthly payments ("Hemat Rp30.000,00"); never below zero. */
    package var yearlySaving: Int {
        max(monthlyPrice * 12 - yearlyPrice, 0)
    }

    /** How many monthly payments a year's price equals ("Bayar 10 bulan untuk 12 bulan"), rounded up. */
    package var yearlyPaidMonths: Int {
        guard monthlyPrice > 0 else { return 0 }
        return (yearlyPrice + monthlyPrice - 1) / monthlyPrice
    }
}
