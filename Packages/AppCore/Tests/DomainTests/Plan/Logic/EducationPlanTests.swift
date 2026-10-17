import Testing

@testable import Domain

/** Pendidikan Anak for Raka, 3: SD to S1, the HasilTujuanPendidikan board. */
@Suite("EducationPlan")
struct EducationPlanTests {
    private let levels = [
        EducationLevel(stage: .primary, entryFee: 23_000_000, fee: 2_000_000, feePeriod: .month, otherRate: 0.10),
        EducationLevel(stage: .juniorHigh, entryFee: 30_000_000, fee: 2_400_000, feePeriod: .month, otherRate: 0.10),
        EducationLevel(stage: .seniorHigh, entryFee: 22_000_000, fee: 1_800_000, feePeriod: .month, otherRate: 0.10),
        EducationLevel(stage: .bachelor, entryFee: 12_000_000, fee: 7_000_000, feePeriod: .semester, otherRate: 0.10),
    ]

    private func plan(
        levels: [EducationLevel]? = nil, income: Int = 15_000_000, deposit: Int = 2_000_000,
        annualReturn: Double? = 0.08
    ) -> EducationPlan {
        EducationPlan(
            childAge: 3, levels: levels ?? self.levels, inflation: 0.15, income: income, present: 20_000_000,
            deposit: deposit, annualReturn: annualReturn)
    }

    @Test("each stage inflated at 15% to its start; 19 years; Belum Cocok; Rp3.300.000 a month")
    func raka() {
        let raka = plan()
        let primary = raka.costs[0]
        #expect(primary.startsInYears == 3 && primary.years == 6)
        #expect(primary.entry == 34_980_125 && primary.tuition == 219_006_000)
        #expect(primary.other == 25_398_612 && primary.total == 279_384_738)
        #expect(raka.target() == 1_849_307_708 && raka.yearsInvesting == 19)
        let projection = raka.projection()
        #expect(projection.result == 1_160_601_164 && projection.principal == 476_000_000 && projection.fit == .short)
        #expect(raka.recommendations() == [.raiseDeposit(to: 3_300_000)])
        #expect(Int(raka.firstMonthlyShare * 1_000) == 223 && raka.depositCap == 4_500_000)
    }

    @Test("Pilih Tipe Target: entry fees only, or with the fees")
    func targets() {
        let raka = plan()
        #expect(raka.target(for: .entryOnly) < raka.target(for: .entryAndTuition))
        #expect(raka.target(for: .entryAndTuition) < raka.target(for: .all))
        #expect(raka.projection(for: .entryOnly).target == raka.target(for: .entryOnly))
    }

    @Test("capped by income, still short: the return rises too; no return yet counts as 0%")
    func capped() {
        let found = plan(income: 3_000_000, deposit: 200_000, annualReturn: nil).recommendations()
        #expect(found.first == .raiseDeposit(to: 600_000))
        guard case .raiseReturn(let rate) = found.last else { return #expect(Bool(false)) }
        #expect(rate > 0 && rate <= 0.30)
        #expect(plan(deposit: 10_000_000).recommendations().isEmpty)
        #expect(plan(annualReturn: nil).projection().result == 20_000_000 + 24_000_000 * 19)
        /** Already above the income share: the deposit stays, and only the return rises, as on the site. */
        let above = plan(income: 3_000_000, annualReturn: nil).recommendations()
        #expect(above.first == .raiseDeposit(to: 2_000_000) && above.count == 2)
    }

    @Test("income brackets 20/30/50/60%; no stages, no years; no income, no share")
    func edges() {
        #expect(plan(income: 3_000_000).depositCap == 600_000)
        #expect(plan(income: 50_000_000).depositCap == 25_000_000)
        #expect(plan(income: 60_000_000).depositCap == 36_000_000)
        #expect(plan(levels: []).yearsInvesting == 0 && plan(income: 0).firstMonthlyShare == 0)
        #expect(plan(levels: []).firstMonthlyShare == 0)
        let late = EducationLevel(stage: .primary, entryFee: 1, fee: 1, feePeriod: .year, otherRate: 0)
        #expect(late.cost(childAge: 9, inflation: 0.15).startsInYears == 0)
        #expect(EducationStage.allCases.map(\.entryAge) == [6, 12, 15, 18])
        #expect(FeePeriod.year.perYear == 1 && FeePeriod.semester.perYear == 2)
    }
}
