import Foundation

/** One of the six indicators with the engine's points, band and what it measured. */
package struct Indicator: Equatable, Sendable {
    package let key: IndicatorKey
    package let group: IndicatorGroup
    package let points: Score
    package let band: ScoreBand
    package let measure: IndicatorMeasure

    package init(key: IndicatorKey, group: IndicatorGroup, points: Score, band: ScoreBand, measure: IndicatorMeasure) {
        self.key = key
        self.group = group
        self.points = points
        self.band = band
        self.measure = measure
    }
}

/** What an indicator measured, in the shape of its key. */
package enum IndicatorMeasure: Equatable, Sendable {
    case emergencyFund(EmergencyFundMeasure)
    /** Monthly savings as a share of income. */
    case savingsRatio(RatioMeasure)
    /** Monthly instalments as a share of income. */
    case instalmentRatio(RatioMeasure)
    case consumerDebt(ConsumerDebtMeasure)
    /** Total debt as a share of total assets. */
    case debtToAsset(RatioMeasure)
    case protection(ProtectionMeasure)
}

/** Liquid money against a month of essential spending. */
package struct EmergencyFundMeasure: Equatable, Sendable {
    /** Liquid ÷ essential, to one decimal, as the engine sent it. */
    package let ratio: Decimal
    package let liquid: Decimal
    package let essential: Decimal
    package let targetMultiple: Int
    package let targetAmount: Decimal

    package init(ratio: Decimal, liquid: Decimal, essential: Decimal, targetMultiple: Int, targetAmount: Decimal) {
        self.ratio = ratio
        self.liquid = liquid
        self.essential = essential
        self.targetMultiple = targetMultiple
        self.targetAmount = targetAmount
    }

    /** Liquid ÷ essential to two decimals, the formula's middle step ("= 1,14×"). */
    package var exactRatio: Decimal { liquid.rounded(2, dividedBy: essential) }

    /** Whether the target multiple is reached. */
    package var hasReachedTarget: Bool { ratio >= Decimal(targetMultiple) }
}

/** A part of a whole as a percentage: savings or instalments of income, debt of assets. */
package struct RatioMeasure: Equatable, Sendable {
    /** The whole percentage the engine sent. */
    package let percent: Int
    package let part: Decimal
    package let whole: Decimal

    package init(percent: Int, part: Decimal, whole: Decimal) {
        self.percent = percent
        self.part = part
        self.whole = whole
    }

    /** Part ÷ whole to two decimals, the formula's middle step ("= 0,18"). */
    package var fraction: Decimal { part.rounded(2, dividedBy: whole) }

    /** `percent`% of the whole, in whole rupiah: a target or a limit on the bar. */
    package func share(_ percent: Int) -> Decimal {
        (whole * Decimal(percent)).rounded(0, dividedBy: 100)
    }
}

/** Consumer debt (paylater, online loans, credit cards): how many platforms, and how it is paid. */
package struct ConsumerDebtMeasure: Equatable, Sendable {
    /** How the platforms are paid. */
    package enum Payment: Equatable, Sendable {
        case onTime
        case late
        case overdue
    }

    package let platforms: Int
    package let anyLate: Bool
    package let anyOverdue: Bool

    package init(platforms: Int, anyLate: Bool, anyOverdue: Bool) {
        self.platforms = platforms
        self.anyLate = anyLate
        self.anyOverdue = anyOverdue
    }

    /** The worst payment state: overdue, then late, else on time. */
    package var payment: Payment {
        if anyOverdue { return .overdue }
        return anyLate ? .late : .onTime
    }
}

/** Basic protection: health cover and income cover. */
package struct ProtectionMeasure: Equatable, Sendable {
    /** Which covers are active. */
    package enum Coverage: Equatable, Sendable {
        case both
        case healthOnly
        case incomeOnly
        case neither
    }

    package let health: Bool
    package let income: Bool

    package init(health: Bool, income: Bool) {
        self.health = health
        self.income = income
    }

    package var coverage: Coverage {
        switch (health, income) {
        case (true, true): .both
        case (true, false): .healthOnly
        case (false, true): .incomeOnly
        case (false, false): .neither
        }
    }

    /** How many of the two covers are active. */
    package var activeCount: Int { (health ? 1 : 0) + (income ? 1 : 0) }
}
