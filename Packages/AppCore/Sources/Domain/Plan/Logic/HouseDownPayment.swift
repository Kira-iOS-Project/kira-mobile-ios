/**
 DP Rumah (REN-02b, REN-04c): the down payment of a house `years` from now, inflated at the
 property rate (5% by default), saved for monthly from what is already put aside.
 */
package struct HouseDownPayment: Equatable, Sendable {
    package let price: Int
    /** The down payment as a fraction of the price (0.20). */
    package let downPaymentRate: Double
    package let inflation: Double
    package let years: Int
    package let present: Int
    package let deposit: Int
    package let annualReturn: Double

    /** A down payment of `downPaymentRate` of `price`, `years` from now. */
    package init(
        price: Int, downPaymentRate: Double, inflation: Double, years: Int, present: Int, deposit: Int,
        annualReturn: Double
    ) {
        self.price = price
        self.downPaymentRate = downPaymentRate
        self.inflation = inflation
        self.years = years
        self.present = present
        self.deposit = deposit
        self.annualReturn = annualReturn
    }

    /** The down payment at today's price. */
    package var downPaymentNow: Int { Rupiah.rounded(downPaymentAmount) }

    /** The rest of today's price, the KPR's principal. */
    package var loanNow: Int { price - downPaymentNow }

    /** The down payment on the day, in whole rupiah. */
    package var target: Int { Rupiah.rounded(targetAmount) }

    /** The plan against that target. */
    package var projection: GoalProjection {
        GoalMath.project(
            target: targetAmount, present: present, deposit: deposit, annualReturn: annualReturn, months: years * 12)
    }

    /** Rekomendasi when the plan falls short. */
    package var recommendations: [GoalRecommendation] {
        GoalRecommender.recommendations(
            cost: downPaymentAmount, inflation: inflation, years: years, present: present, deposit: deposit,
            annualReturn: annualReturn)
    }

    private var downPaymentAmount: Double { Double(price) * downPaymentRate }

    private var targetAmount: Double {
        GoalMath.inflatedAmount(downPaymentAmount, rate: inflation, years: Double(years))
    }
}
