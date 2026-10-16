/** One indicator in full: its ladder of points, the next rung and the bar's milestones. */
package struct IndicatorDetail: Equatable, Sendable {
    /** The indicator, as the score lists it. */
    package let indicator: ScoreIndicator
    /** The rungs from the most points to the fewest. */
    package let ladder: [LadderRung]
    /** The rung above the current one, nil at the top. */
    package let nextRung: NextRung?
    /** The labelled points of the "Posisimu" bar. */
    package let milestones: [Milestone]

    /** The detail with every field given. */
    package init(indicator: ScoreIndicator, ladder: [LadderRung], nextRung: NextRung?, milestones: [Milestone]) {
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
    /** The points the rung gives. */
    package let points: Int
    /** The low end, a multiple for the emergency fund and a percentage elsewhere. */
    package let lower: Double?
    /** The high end; nil for the top of a more-is-better ladder or the bottom of a less-is-better one. */
    package let upper: Double?
    /** The low end in rupiah, for this person's numbers. */
    package let amountLower: Int?
    /** The high end in rupiah. */
    package let amountUpper: Int?
    /** Whether the person stands on this rung ("Kamu di Sini"). */
    package let isCurrent: Bool

    /** The rung with every field given. */
    package init(points: Int, lower: Double?, upper: Double?, amountLower: Int?, amountUpper: Int?, isCurrent: Bool) {
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
        /** The multiple or the percentage. */
        package let multiple: Double
        /** The same bound in rupiah. */
        package let amount: Int
    }

    /** The top rung where more is better. */
    case atLeast(Bound)
    /** A middle rung where more is better. */
    case from(Bound)
    /** The rung below every other. */
    case under(Int)
    /** A middle rung where less is better. */
    case between(Int, Int)
    /** The bottom rung where less is better. */
    case over(Int)
    /** A rung named by its rule, with no amounts. */
    case fixed
}

/** The next rung up and what it takes. */
package struct NextRung: Equatable, Sendable {
    /** The points of the rung. */
    package let points: Int
    /** What it takes in rupiah, nil for the rule-based indicators. */
    package let amountNeeded: Int?
    /** The Kira Score today. */
    package let scoreFrom: Int
    /** The Kira Score once there. */
    package let scoreTo: Int

    /** The next rung with every field given. */
    package init(points: Int, amountNeeded: Int?, scoreFrom: Int, scoreTo: Int) {
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
    /** Where it sits, in rupiah (the API's `at`). */
    package let amount: Int
    /** Its label, as the engine wrote it. */
    package let label: String

    /** A milestone at `amount`. */
    package init(amount: Int, label: String) {
        self.amount = amount
        self.label = label
    }
}
