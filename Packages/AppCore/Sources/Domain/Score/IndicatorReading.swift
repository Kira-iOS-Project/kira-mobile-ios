import Foundation

/**
 What the screens say about an indicator's measure, decided from the engine's numbers: the line
 under its value ("Cukup untuk bertahan sekitar satu bulan."), the target beside it in the list,
 and the bar of its "Posisimu" card. The words live in the String Catalog; this picks which.
 */
extension IndicatorMeasure {
    /** The line under the measured value in "Posisimu". */
    package var position: IndicatorPosition {
        switch self {
        case .emergencyFund(let fund):
            if fund.essential == 0 { return .missingBase }
            if fund.hasReachedTarget { return .reachedGoal }
            let months = NSDecimalNumber(decimal: fund.ratio.rounded(0, dividedBy: 1)).intValue
            return fund.ratio < 1 ? .belowGoal : .monthsCovered(max(months, 1))
        case .savingsRatio(let ratio):
            if ratio.whole == 0 { return .missingBase }
            if ratio.percent >= 20 { return .reachedGoal }
            return ratio.percent >= 10 ? .betweenGoals : .belowGoal
        case .instalmentRatio(let ratio), .debtToAsset(let ratio):
            if ratio.part == 0 { return .nothingOwed }
            if ratio.whole == 0 { return .missingBase }
            return ratio.percent <= limitPercent ? .withinLimit : .overLimit
        case .consumerDebt(let debt):
            if debt.platforms == 0 { return .nothingOwed }
            switch debt.payment {
            case .onTime: return .withinLimit
            case .late: return .belowGoal
            case .overdue: return .overLimit
            }
        case .protection(let cover):
            return cover.activeCount == 2 ? .reachedGoal : .belowGoal
        }
    }

    /** The limit the bar of a less-is-better ratio runs to: 30% of income, 50% of assets. */
    private var limitPercent: Int {
        if case .instalmentRatio = self { return 30 }
        return 50
    }

    /** What follows the value in the indicator list ("target 6×", "batas 30%"), if anything. */
    package var rowTarget: IndicatorTarget? {
        switch self {
        case .emergencyFund(let fund):
            return fund.hasReachedTarget ? nil : .multiple(fund.targetMultiple)
        case .savingsRatio(let ratio):
            if ratio.percent >= 20 { return nil }
            return ratio.percent < 10 ? .minimumPercent(10) : .targetPercent(20)
        case .instalmentRatio(let ratio), .debtToAsset(let ratio):
            return ratio.part == 0 ? nil : .limitPercent(limitPercent)
        case .consumerDebt, .protection:
            return nil
        }
    }

    /** The bar of "Posisimu"; consumer debt and protection have none. */
    package var ribbon: IndicatorRibbon? {
        switch self {
        case .emergencyFund(let fund):
            return IndicatorRibbon(value: fund.liquid, target: fund.targetAmount, isLimit: false, isMonthly: false)
        case .savingsRatio(let ratio):
            return IndicatorRibbon(value: ratio.part, target: ratio.share(20), isLimit: false, isMonthly: true)
        case .instalmentRatio(let ratio):
            return IndicatorRibbon(value: ratio.part, target: ratio.share(30), isLimit: true, isMonthly: true)
        case .debtToAsset(let ratio):
            return IndicatorRibbon(value: ratio.part, target: ratio.share(50), isLimit: true, isMonthly: false)
        case .consumerDebt, .protection:
            return nil
        }
    }
}

/** Where the measure stands, for the line under the value. */
package enum IndicatorPosition: Equatable, Sendable {
    /** Below the first goal, a late payment, or a cover missing. */
    case belowGoal
    /** Past the first goal, short of the last (savings 10–19%). */
    case betweenGoals
    /** The goal is reached. */
    case reachedGoal
    /** The emergency fund lasts about this many months. */
    case monthsCovered(Int)
    /** Under the limit (instalments, debt to assets), or consumer debt paid on time. */
    case withinLimit
    /** Over the limit, or consumer debt overdue. */
    case overLimit
    /** No debt or instalment at all. */
    case nothingOwed
    /** The base of the ratio (income, essentials, assets) is not filled in. */
    case missingBase
}

/** The target after an indicator's value in the list. */
package enum IndicatorTarget: Equatable, Sendable {
    case multiple(Int)
    case minimumPercent(Int)
    case targetPercent(Int)
    case limitPercent(Int)
}

/** The bar of "Posisimu": the measure against its target or its limit. */
package struct IndicatorRibbon: Equatable, Sendable {
    package let value: Decimal
    package let target: Decimal
    /** A limit to stay under, rather than a target to reach. */
    package let isLimit: Bool
    /** Counted per month. */
    package let isMonthly: Bool
}
