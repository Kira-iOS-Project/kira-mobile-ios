import Testing

@testable import Domain

@Suite("IndicatorDetail")
struct IndicatorDetailTests {
    private func detail(_ key: IndicatorKey, ladder: [LadderRung], next: NextRung? = nil) -> IndicatorDetail {
        IndicatorDetail(
            indicator: ScoreIndicator(
                key: key, group: .save, points: 50, band: .coping,
                measure: .protectionCover(health: true, income: true)),
            ladder: ladder, nextRung: next, milestones: [Milestone(at: 4_200_000, label: "1×")])
    }

    private func rung(
        _ points: Int, _ lower: Double?, _ upper: Double?, _ amountLower: Int?, _ amountUpper: Int?
    ) -> LadderRung {
        LadderRung(
            points: points, lower: lower, upper: upper, amountLower: amountLower, amountUpper: amountUpper,
            isCurrent: points == 50)
    }

    @Test("writes the rungs of a more-is-better indicator from where each starts")
    func moreIsBetter() {
        let detail = detail(.emergencyFund, ladder: [])
        let top = RungRange.Bound(multiple: 6, amount: 25_200_000)
        #expect(detail.range(of: rung(100, 6, nil, 25_200_000, nil)) == .atLeast(top))
        #expect(
            detail.range(of: rung(50, 1, 3, 4_200_000, 12_600_000))
                == .from(RungRange.Bound(multiple: 1, amount: 4_200_000)))
        #expect(detail.range(of: rung(0, nil, 0.5, nil, 2_100_000)) == .under(2_100_000))
        #expect(detail.range(of: rung(0, nil, nil, nil, nil)) == .under(0))
        #expect(detail.range(of: rung(25, 1, 2, nil, nil)) == .from(RungRange.Bound(multiple: 1, amount: 0)))
        #expect(detail.milestones.first?.label == "1×")
    }

    @Test("writes the rungs of a less-is-better indicator as ranges of amounts")
    func lessIsBetter() {
        let detail = detail(.instalmentRatio, ladder: [])
        #expect(detail.range(of: rung(100, nil, 10, nil, 750_000)) == .under(750_000))
        #expect(detail.range(of: rung(85, 10, 15, 750_000, 1_125_000)) == .between(750_000, 1_125_000))
        #expect(detail.range(of: rung(0, 40, nil, 3_000_000, nil)) == .over(3_000_000))
        #expect(detail.range(of: rung(100, nil, nil, nil, nil)) == .under(0))
    }

    @Test("names the rungs of consumer debt and protection by their rule")
    func fixed() {
        #expect(detail(.consumerDebt, ladder: []).range(of: rung(75, nil, nil, nil, nil)) == .fixed)
        #expect(detail(.protection, ladder: []).range(of: rung(50, nil, nil, nil, nil)) == .fixed)
    }

    @Test("finds the rung the next step reaches and what it adds")
    func nextRung() {
        let ladder = [rung(100, 6, nil, 25_200_000, nil), rung(75, 3, 6, 12_600_000, 25_200_000)]
        let next = NextRung(points: 75, amountNeeded: 7_800_000, scoreFrom: 66, scoreTo: 70)
        #expect(detail(.emergencyFund, ladder: ladder, next: next).nextRungTarget == ladder[1])
        #expect(detail(.emergencyFund, ladder: ladder).nextRungTarget == nil)
        #expect(next.gain == 4)
    }
}
