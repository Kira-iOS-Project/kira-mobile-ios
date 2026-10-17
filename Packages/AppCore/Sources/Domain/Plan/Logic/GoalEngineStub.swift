/**
 TEMPORARY (R2b): the goal engine's API as kira-project-d5 announced it for Domain/Plan, so the goal
 screens build before R2c's commit. Deleted when R2c lands; nothing here ships.
 */
import Foundation

/** Whether a strategy reaches its target: ≥100%, ≥90%, or short. */
package enum GoalFit: Equatable, Sendable {
    /** "Strategimu Cocok". */
    case fits
    /** "Hampir Cocok". */
    case nearlyFits
    /** "Belum Cocok". */
    case short
}

/** When a deposit is made within its period. */
package enum DepositTiming: Equatable, Sendable {
    /** "Awal". */
    case start
    /** "Akhir". */
    case end
}

/** How often a deposit is made. */
package enum DepositPeriod: Equatable, Sendable {
    /** "Bulan". */
    case month
    /** "Tahun". */
    case year
}

/** What a strategy reaches against its target, rounded once at the end. */
package struct GoalProjection: Equatable, Sendable {
    /** The target, inflated where the kind inflates. */
    package let target: Int
    /** The future value of what is there and every deposit. */
    package let result: Int
    /** What is there plus every deposit ("Pokok"). */
    package let principal: Int
    /** The result less the principal ("Imbal Hasil"). */
    package let growth: Int
    /** The target less the result, never below zero ("Kurang"). */
    package let shortfall: Int
    /** The result over the target, unrounded. */
    package let share: Double
    /** The status the share gives. */
    package let fit: GoalFit

    /** A projection of these figures. */
    package init(
        target: Int, result: Int, principal: Int, growth: Int, shortfall: Int, share: Double, fit: GoalFit
    ) {
        self.target = target
        self.result = result
        self.principal = principal
        self.growth = growth
        self.shortfall = shortfall
        self.share = share
        self.fit = fit
    }
}

/** A way to reach a target that is short. */
package enum GoalRecommendation: Equatable, Sendable {
    /** "Naikkan Investasi": the deposit that reaches it. */
    case raiseDeposit(to: Int)
    /** "Pilih Return Lebih Tinggi": the yearly return that reaches it. */
    case raiseReturn(to: Double)
    /** "Perpanjang Waktu": the years that reach it, and the target then. */
    case extendYears(to: Int, target: Int)
    /** "Perpanjang Waktu" in months. */
    case extendMonths(to: Int)
}

/** An asset class for a horizon, never a product. */
package enum GoalAssetClass: Equatable, Sendable, CaseIterable {
    case moneyMarket, shortTermDeposit, fixedIncomeFund, governmentBond, stocks, indexFund, balancedFund, etf, gold
    case crypto
}

/** The goal calculators of feliciaputritjiasaka.com. */
package enum GoalMath {
    /** `cost` after `years` of `rate` inflation, rounded. */
    package static func inflated(_ cost: Int, rate: Double, years: Int) -> Int {
        Int(inflatedAmount(cost, rate: rate, years: Double(years)).rounded())
    }

    /** `cost` after `years` (a fraction for months) of `rate` inflation, unrounded. */
    package static func inflatedAmount(_ cost: Int, rate: Double, years: Double) -> Double {
        Double(cost) * pow(1 + rate, years)
    }

    /** A year of `monthlyExpense` inflated over `years`, and the target it needs at a 4% withdrawal. */
    package static func retirementTarget(monthlyExpense: Int, inflation: Double, years: Int) -> (
        annualExpense: Int, target: Int
    ) {
        let annual = Double(monthlyExpense * 12) * pow(1 + inflation, Double(years))
        return (Int(annual.rounded()), Int((annual / 0.04).rounded()))
    }

    /** What `present` and `deposit` reach in `months` at `annualReturn`, against `target`. */
    package static func project(
        target: Double, present: Int, deposit: Int, annualReturn: Double, months: Int,
        period: DepositPeriod = .month, timing: DepositTiming = .start
    ) -> GoalProjection {
        let perYear = period == .month ? 12.0 : 1.0
        let periods = period == .month ? Double(months) : Double(months) / 12
        let rate = annualReturn / perYear
        let growth = pow(1 + rate, periods)
        let annuity = rate == 0 ? periods : (growth - 1) / rate * (timing == .start ? 1 + rate : 1)
        let result = Double(present) * growth + Double(deposit) * annuity
        let principal = Double(present) + Double(deposit) * periods
        let share = target > 0 ? result / target : 1
        let fit: GoalFit = share >= 1 ? .fits : share >= 0.9 ? .nearlyFits : .short
        return GoalProjection(
            target: Int(target.rounded()), result: Int(result.rounded()), principal: Int(principal.rounded()),
            growth: Int((result - principal).rounded()), shortfall: Int(max(target - result, 0).rounded()),
            share: share, fit: fit)
    }

    /** The classes for a horizon of `years`. */
    package static func assetClasses(years: Double) -> [GoalAssetClass] {
        if years < 1 { return [.moneyMarket, .shortTermDeposit] }
        if years <= 5 { return [.fixedIncomeFund, .governmentBond] }
        if years <= 10 { return [.stocks, .indexFund, .balancedFund, .etf, .gold] }
        return [.stocks, .crypto, .indexFund, .etf]
    }
}

/** The recommendations for a target that is short (R2c fills these in). */
package enum GoalRecommender {
    /** None until R2c lands. */
    package static func recommendations(
        cost: Int, inflation: Double, years: Int, present: Int, deposit: Int, annualReturn: Double,
        offersYears: Bool = true
    ) -> [GoalRecommendation] {
        []
    }

    /** None until R2c lands (Barang Impian, month-based). */
    package static func recommendations(
        cost: Int, inflation: Double, months: Int, present: Int, deposit: Int, annualReturn: Double
    ) -> [GoalRecommendation] {
        []
    }
}
