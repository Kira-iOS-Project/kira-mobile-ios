import Foundation

/**
 The calculators' arithmetic, as feliciaputritjiasaka.com computes it: Excel's FV with the
 deposit at the start of each period and today's savings as the present value, targets inflated
 by (1 + inflation)^years, and the asset classes for a horizon.
 */
package enum GoalMath {
    /** The site's FV: `present` and `periods` deposits of `payment` grown at `rate` per period. */
    package static func futureValue(
        rate: Double, periods: Int, payment: Double, present: Double, timing: DepositTiming = .start
    ) -> Double {
        let count = Double(periods)
        guard rate != 0 else { return present + payment * count }
        let growth = pow(1 + rate, count)
        let start: Double = timing == .start ? 1 : 0
        return present * growth + payment * (1 + rate * start) * (growth - 1) / rate
    }

    /** `cost` today, `years` from now at `rate` inflation a year, unrounded; Barang passes months ÷ 12. */
    package static func inflatedAmount(_ cost: Double, rate: Double, years: Double) -> Double {
        cost * pow(1 + rate, years)
    }

    /** `cost` today, `years` from now, in whole rupiah. */
    package static func inflated(_ cost: Int, rate: Double, years: Int) -> Int {
        Rupiah.rounded(inflatedAmount(Double(cost), rate: rate, years: Double(years)))
    }

    /**
     Dana Pensiun: the year's expenses on retirement day (`monthlyExpense` × 12, inflated over
     `years`), and the fund that pays them for good at a 4% yearly withdrawal.
     */
    package static func retirementTarget(
        monthlyExpense: Int, inflation: Double, years: Int
    ) -> (annualExpense: Int, target: Int) {
        let annual = inflatedAmount(Double(monthlyExpense) * 12, rate: inflation, years: Double(years))
        return (Rupiah.rounded(annual), Rupiah.rounded(annual / retirementWithdrawal))
    }

    /** The safe withdrawal of Dana Pensiun: 4% of the fund a year. */
    package static let retirementWithdrawal = 0.04

    /**
     The plan of `deposit` each `period` for `months`, growing at `annualReturn` from `present`,
     against `target`. Monthly plans compound monthly; yearly ones compound yearly over whole years.
     */
    package static func project(
        target: Double, present: Int, deposit: Int, annualReturn: Double, months: Int,
        period: DepositPeriod = .month, timing: DepositTiming = .start
    ) -> GoalProjection {
        let periods = period == .month ? months : months / 12
        let rate = period == .month ? annualReturn / 12 : annualReturn
        let result = futureValue(
            rate: rate, periods: periods, payment: Double(deposit), present: Double(present), timing: timing)
        let principal = Double(present) + Double(deposit) * Double(periods)
        return GoalProjection(target: target, result: result, principal: principal)
    }

    /** The site's classes for a horizon of `years`: shorter is safer. */
    package static func assetClasses(years: Double) -> [GoalAssetClass] {
        if years < 1 { return [.moneyMarket, .shortTermDeposit] }
        if years <= 5 { return [.fixedIncomeFund, .governmentBond] }
        if years <= 10 { return [.stocks, .indexFund, .balancedFund, .etf, .gold] }
        return [.stocks, .crypto, .indexFund, .etf]
    }
}
