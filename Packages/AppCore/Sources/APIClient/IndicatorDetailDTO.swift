/** One indicator in detail (DetailIndikator*): its Aturan Nilai, the next rung and its ribbon. */

/** One rung of the indicator's ladder. */
package struct LadderRungDTO: Hashable, Sendable {
    /** The rung's points. */
    package let points: Int
    /** Where it starts: a multiple for the emergency fund, a percent elsewhere; nil when open. */
    package let lower: Double?
    /** Where it ends, in the same unit; nil when open. */
    package let upper: Double?
    /** `lower` in rupiah; nil without a base amount. */
    package let amountLower: Int?
    /** `upper` in rupiah. */
    package let amountUpper: Int?
    /** "Kamu di Sini". */
    package let isCurrent: Bool
}

/** The rung above, and what reaching it would do ("+4 Kira Score · perkiraan 66 → 70"). */
package struct NextRungDTO: Hashable, Sendable {
    /** The rung's points. */
    package let points: Int
    /** Rupiah to add (or to cut, for debt) to get there; nil when not an amount. */
    package let amountNeeded: Int?
    /** The score now. */
    package let scoreFrom: Int
    /** The score with this rung reached. */
    package let scoreTo: Int
}

/** A mark on the progress ribbon ("3×", "15%"). */
package struct MilestoneDTO: Hashable, Sendable {
    /** Where it sits, in rupiah. */
    package let amount: Int
    /** Its label, already written. */
    package let label: String
}

/** The indicator, its ladder from the best rung down, the next rung and the milestones. */
package struct IndicatorDetailDTO: Hashable, Sendable {
    /** The indicator as the score report shows it. */
    package let indicator: IndicatorDTO
    /** Aturan Nilai, best rung first. */
    package let ladder: [LadderRungDTO]
    /** The rung above; nil at the top. */
    package let nextRung: NextRungDTO?
    /** The ribbon's marks. */
    package let milestones: [MilestoneDTO]

    init(_ detail: Components.Schemas.IndicatorDetail) throws {
        indicator = try IndicatorDTO(detail.value1)
        ladder = detail.value2.ladder.map {
            LadderRungDTO(
                points: $0.points, lower: $0.lower, upper: $0.upper, amountLower: $0.amountLower,
                amountUpper: $0.amountUpper, isCurrent: $0.isCurrent)
        }
        nextRung = detail.value2.nextRung.map {
            NextRungDTO(points: $0.points, amountNeeded: $0.amountNeeded, scoreFrom: $0.scoreFrom, scoreTo: $0.scoreTo)
        }
        milestones = detail.value2.milestones.map { MilestoneDTO(amount: $0.at, label: $0.label) }
    }
}
