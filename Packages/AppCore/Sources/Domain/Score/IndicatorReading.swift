/**
 What the screens say about an indicator's measure, decided from the engine's numbers: the line
 under its value ("Cukup untuk bertahan sekitar satu bulan."), the target beside it in the list,
 and the bar of its "Posisimu" card. The words live in the String Catalog; this picks which.
 */
extension IndicatorMeasure {
    /** The line under the measured value in "Posisimu". */
    package var position: IndicatorPosition {
        switch self {
        case .emergencyFund(let ratio, _, let essential, let target, _):
            if essential == 0 { return .missingBase }
            if ratio >= Double(target) { return .reachedGoal }
            return ratio < 1 ? .belowGoal : .monthsCovered(Int(ratio.rounded()))
        case .savingsRatio(let percent, _, let income):
            if income == 0 { return .missingBase }
            if percent >= 20 { return .reachedGoal }
            return percent >= 10 ? .betweenGoals : .belowGoal
        case .instalmentRatio(let percent, let part, let whole), .debtToAsset(let percent, let part, let whole):
            if part == 0 { return .nothingOwed }
            if whole == 0 { return .missingBase }
            return percent <= limitPercent ? .withinLimit : .overLimit
        case .consumerDebt(let platforms, _, _):
            if platforms == 0 { return .nothingOwed }
            switch payment {
            case .onTime: return .withinLimit
            case .late: return .belowGoal
            case .overdue: return .overLimit
            }
        case .protectionCover:
            return coverage == .both ? .reachedGoal : .belowGoal
        }
    }

    /** The limit of a less-is-better ratio: 30% of income, 50% of assets. */
    private var limitPercent: Int {
        if case .instalmentRatio = self { return 30 }
        return 50
    }

    /** What follows the value in the indicator list ("target 6×", "batas 30%"), if anything. */
    package var rowTarget: IndicatorTarget? {
        switch self {
        case .emergencyFund(let ratio, _, _, let target, _):
            return ratio >= Double(target) ? nil : .multiple(target)
        case .savingsRatio(let percent, _, _):
            if percent >= 20 { return nil }
            return percent < 10 ? .minimumPercent(10) : .targetPercent(20)
        case .instalmentRatio(_, let part, _), .debtToAsset(_, let part, _):
            return part == 0 ? nil : .limitPercent(limitPercent)
        case .consumerDebt, .protectionCover:
            return nil
        }
    }

    /** The bar of "Posisimu"; consumer debt and protection have none. */
    package var ribbon: IndicatorRibbon? {
        guard let division else { return nil }
        switch self {
        case .emergencyFund(_, _, _, _, let targetAmount):
            return IndicatorRibbon(value: division.part, target: targetAmount, isLimit: false, isMonthly: false)
        case .savingsRatio:
            return IndicatorRibbon(value: division.part, target: division.share(20), isLimit: false, isMonthly: true)
        case .instalmentRatio:
            return IndicatorRibbon(value: division.part, target: division.share(30), isLimit: true, isMonthly: true)
        default:
            return IndicatorRibbon(value: division.part, target: division.share(50), isLimit: true, isMonthly: false)
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

/** The bar of "Posisimu": the measure against its target or its limit, in whole rupiah. */
package struct IndicatorRibbon: Equatable, Sendable {
    package let value: Int
    package let target: Int
    /** A limit to stay under, rather than a target to reach. */
    package let isLimit: Bool
    /** Counted per month. */
    package let isMonthly: Bool
}
