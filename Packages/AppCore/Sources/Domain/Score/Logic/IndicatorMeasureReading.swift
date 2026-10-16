/**
 The numbers the indicator screens write out from a measure: the division of its formula, the
 worst consumer-debt payment, and which protection covers are active.
 */
extension IndicatorMeasure {
    /** The division of a ratio's formula, part over whole; nil for the rule-based indicators. */
    package var division: Division? {
        switch self {
        case .emergencyFund(_, let liquid, let essential, _, _): Division(part: liquid, whole: essential)
        case .savingsRatio(_, let savings, let income): Division(part: savings, whole: income)
        case .instalmentRatio(_, let instalments, let income): Division(part: instalments, whole: income)
        case .debtToAsset(_, let debt, let assets): Division(part: debt, whole: assets)
        case .consumerDebt, .protectionCover: nil
        }
    }

    /** The worst payment of consumer debt: overdue, then late, else on time. */
    package var payment: ConsumerPayment {
        guard case .consumerDebt(_, let anyLate, let anyOverdue) = self else { return .onTime }
        if anyOverdue { return .overdue }
        return anyLate ? .late : .onTime
    }

    /** Which protection covers are active; `.neither` for every other indicator. */
    package var coverage: Coverage {
        guard case .protectionCover(let health, let income) = self else { return .neither }
        switch (health, income) {
        case (true, true): return .both
        case (true, false): return .healthOnly
        case (false, true): return .incomeOnly
        case (false, false): return .neither
        }
    }
}

/** Part ÷ whole, in whole rupiah. */
package struct Division: Equatable, Sendable {
    /** What is divided: the fund, savings, instalments or debt. */
    package let part: Int
    /** What it is divided by: essentials, income or assets. */
    package let whole: Int

    /** The quotient unrounded ("1,14" once written to two decimals), 0 when the whole is 0. */
    package var quotient: Double { whole == 0 ? 0 : Double(part) / Double(whole) }

    /** `percent`% of the whole, rounded half up to whole rupiah: a target or a limit on the bar. */
    package func share(_ percent: Int) -> Int { (whole * percent + 50) / 100 }
}

/** How consumer debt is paid. */
package enum ConsumerPayment: Equatable, Sendable {
    /** Every platform paid on time. */
    case onTime
    /** A payment was late. */
    case late
    /** A payment is past due. */
    case overdue
}

/** Which of the two basic covers are active. */
package enum Coverage: Equatable, Sendable {
    /** Health and income cover. */
    case both
    /** Health cover only. */
    case healthOnly
    /** Income cover only. */
    case incomeOnly
    /** No cover. */
    case neither

    /** How many of the two covers are active. */
    package var activeCount: Int {
        switch self {
        case .both: 2
        case .healthOnly, .incomeOnly: 1
        case .neither: 0
        }
    }
}
