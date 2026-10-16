import Foundation

/** One indicator in full: its ladder of points, the next rung and the bar's milestones. */
package struct IndicatorDetail: Equatable, Sendable {
    package let indicator: Indicator
    /** The rungs from the most points to the fewest. */
    package let ladder: [LadderRung]
    package let nextRung: NextRung?
    package let milestones: [Milestone]

    package init(indicator: Indicator, ladder: [LadderRung], nextRung: NextRung?, milestones: [Milestone]) {
        self.indicator = indicator
        self.ladder = ladder
        self.nextRung = nextRung
        self.milestones = milestones
    }

    /** The rung the next step reaches. */
    package var nextRungTarget: LadderRung? {
        nextRung.flatMap { next in ladder.first { $0.points == next.points } }
    }

    /** What a rung's second line says. */
    package func range(of rung: LadderRung) -> RungRange {
        switch indicator.key {
        case .consumerDebt, .protection:
            return .fixed
        case .emergencyFund, .savingsRatio:
            guard let lower = rung.lower else { return .under(rung.amountUpper ?? 0) }
            let from = RungRange.Bound(multiple: lower, amount: rung.amountLower ?? 0)
            return rung.upper == nil ? .atLeast(from) : .from(from)
        case .instalmentRatio, .debtToAsset:
            guard let amountLower = rung.amountLower, rung.lower != nil else { return .under(rung.amountUpper ?? 0) }
            guard let amountUpper = rung.amountUpper, rung.upper != nil else { return .over(amountLower) }
            return .between(amountLower, amountUpper)
        }
    }
}

/** One rung of an indicator's ladder: its points and the range of the measure it covers. */
package struct LadderRung: Equatable, Sendable {
    package let points: Score
    /** The low end, a multiple for the emergency fund and a percentage elsewhere. */
    package let lower: Decimal?
    package let upper: Decimal?
    package let amountLower: Decimal?
    package let amountUpper: Decimal?
    package let isCurrent: Bool

    package init(
        points: Score, lower: Decimal?, upper: Decimal?, amountLower: Decimal?, amountUpper: Decimal?, isCurrent: Bool
    ) {
        self.points = points
        self.lower = lower
        self.upper = upper
        self.amountLower = amountLower
        self.amountUpper = amountUpper
        self.isCurrent = isCurrent
    }
}

/** The second line of a rung ("Mulai 3× · Rp12.600.000,00", "Kurang dari Rp750.000,00"). */
package enum RungRange: Equatable, Sendable {
    /** Where a rung starts: a multiple or a percentage, and its amount. */
    package struct Bound: Equatable, Sendable {
        package let multiple: Decimal
        package let amount: Decimal
    }

    /** The top rung where more is better. */
    case atLeast(Bound)
    /** A middle rung where more is better. */
    case from(Bound)
    /** The rung below every other. */
    case under(Decimal)
    /** A middle rung where less is better. */
    case between(Decimal, Decimal)
    /** The bottom rung where less is better. */
    case over(Decimal)
    /** A rung named by its rule, with no amounts. */
    case fixed
}

/** The next rung up and what it takes. */
package struct NextRung: Equatable, Sendable {
    package let points: Score
    package let amountNeeded: Decimal?
    package let scoreFrom: Int
    package let scoreTo: Int

    package init(points: Score, amountNeeded: Decimal?, scoreFrom: Int, scoreTo: Int) {
        self.points = points
        self.amountNeeded = amountNeeded
        self.scoreFrom = scoreFrom
        self.scoreTo = scoreTo
    }

    /** Kira Score points the rung adds. */
    package var gain: Int { scoreTo - scoreFrom }
}

/** A labelled point on the indicator's bar ("3×", "10%"). */
package struct Milestone: Equatable, Sendable {
    package let at: Decimal
    package let label: String

    package init(at: Decimal, label: String) {
        self.at = at
        self.label = label
    }
}
