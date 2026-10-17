/**
 The canvas's six indicators (boards DetailIndikator, …Menabung, …Cicilan, …Konsumtif, …Aset,
 …Proteksi): Dinda, income Rp7.500.000,00, Kira Score 66.
 */
import Domain

nonisolated extension ScoreIndicator {
    /** The board's indicator for `key`. */
    static func sample(_ key: IndicatorKey) -> ScoreIndicator {
        switch key {
        case .emergencyFund:
            ScoreIndicator(
                key: key, group: .save, points: 50, band: .coping,
                measure: .emergencyFund(
                    ratio: 1.1, liquid: 4_800_000, essential: 4_200_000, targetMultiple: 6, targetAmount: 25_200_000))
        case .savingsRatio:
            ScoreIndicator(
                key: key, group: .save, points: 45, band: .coping,
                measure: .savingsRatio(percent: 8, monthlySavings: 600_000, income: 7_500_000))
        case .instalmentRatio:
            ScoreIndicator(
                key: key, group: .debt, points: 70, band: .coping,
                measure: .instalmentRatio(percent: 18, monthlyInstalments: 1_350_000, income: 7_500_000))
        case .consumerDebt:
            ScoreIndicator(
                key: key, group: .debt, points: 50, band: .coping,
                measure: .consumerDebt(platforms: 2, anyLate: false, anyOverdue: false))
        case .debtToAsset:
            ScoreIndicator(
                key: key, group: .debt, points: 80, band: .healthy,
                measure: .debtToAsset(percent: 32, totalDebt: 14_310_000, totalAssets: 44_700_000))
        case .protection:
            ScoreIndicator(
                key: key, group: .protect, points: 100, band: .healthy,
                measure: .protectionCover(health: true, income: true))
        }
    }
}

nonisolated extension IndicatorDetail {
    /**
     Utang Konsumtif with four platforms, all paid on time (KIR-126): 25 points, the rung of "4+
     Platform atau Ada Keterlambatan"; the next step asks only to pay off down to three.
     */
    static let consumerDebtManyOnTime: IndicatorDetail = {
        let indicator = ScoreIndicator(
            key: .consumerDebt, group: .debt, points: 25, band: .vulnerable,
            measure: .consumerDebt(platforms: 4, anyLate: false, anyOverdue: false))
        let ladder = rungs(.consumerDebt).map { rung in
            LadderRung(
                points: rung.points, lower: nil, upper: nil, amountLower: nil, amountUpper: nil,
                isCurrent: rung.points == indicator.points)
        }
        return IndicatorDetail(
            indicator: indicator, ladder: ladder,
            nextRung: NextRung(points: 50, amountNeeded: nil, scoreFrom: 66, scoreTo: 69), milestones: [])
    }()

    /** The board's detail for `key`. */
    static func sample(_ key: IndicatorKey) -> IndicatorDetail {
        let indicator = ScoreIndicator.sample(key)
        let ladder = rungs(key).map { rung in
            LadderRung(
                points: rung.points, lower: rung.lower, upper: rung.upper, amountLower: rung.amountLower,
                amountUpper: rung.amountUpper, isCurrent: rung.points == indicator.points)
        }
        return IndicatorDetail(
            indicator: indicator, ladder: ladder, nextRung: next(key),
            milestones: milestones(key).map { Milestone(amount: $0.0, label: $0.1) })
    }

    /** A rung of the board, not yet marked current. */
    private static func row(
        _ points: Int, _ lower: Double?, _ upper: Double?, _ amountLower: Int?, _ amountUpper: Int?
    ) -> LadderRung {
        LadderRung(
            points: points, lower: lower, upper: upper, amountLower: amountLower, amountUpper: amountUpper,
            isCurrent: false)
    }

    private static func rungs(_ key: IndicatorKey) -> [LadderRung] {
        switch key {
        case .emergencyFund:
            return [
                row(100, 6, nil, 25_200_000, nil), row(75, 3, 6, 12_600_000, 25_200_000),
                row(50, 1, 3, 4_200_000, 12_600_000),
                row(25, 0.5, 1, 2_100_000, 4_200_000), row(0, nil, 0.5, nil, 2_100_000),
            ]
        case .savingsRatio:
            return [
                row(100, 20, nil, 1_500_000, nil), row(75, 10, 20, 750_000, 1_500_000),
                row(45, 5, 10, 375_000, 750_000),
                row(25, 1, 5, 75_000, 375_000), row(0, nil, 1, nil, 75_000),
            ]
        case .instalmentRatio:
            return [
                row(100, nil, 10, nil, 750_000), row(85, 10, 15, 750_000, 1_125_000),
                row(70, 15, 30, 1_125_000, 2_250_000),
                row(40, 30, 40, 2_250_000, 3_000_000), row(0, 40, nil, 3_000_000, nil),
            ]
        case .debtToAsset:
            return [
                row(100, nil, 20, nil, 8_940_000), row(80, 20, 40, 8_940_000, 17_880_000),
                row(50, 40, 50, 17_880_000, 22_350_000), row(25, 50, 70, 22_350_000, 31_290_000),
                row(0, 70, nil, 31_290_000, nil),
            ]
        case .consumerDebt:
            return [100, 75, 50, 25, 0].map { row($0, nil, nil, nil, nil) }
        case .protection:
            return [100, 50, 0].map { row($0, nil, nil, nil, nil) }
        }
    }

    private static func next(_ key: IndicatorKey) -> NextRung? {
        switch key {
        case .emergencyFund: NextRung(points: 75, amountNeeded: 7_800_000, scoreFrom: 66, scoreTo: 70)
        case .savingsRatio: NextRung(points: 75, amountNeeded: 150_000, scoreFrom: 66, scoreTo: 70)
        case .instalmentRatio: NextRung(points: 85, amountNeeded: 225_000, scoreFrom: 66, scoreTo: 68)
        case .consumerDebt: NextRung(points: 75, amountNeeded: nil, scoreFrom: 66, scoreTo: 69)
        case .debtToAsset: NextRung(points: 100, amountNeeded: 5_370_000, scoreFrom: 66, scoreTo: 69)
        case .protection: nil
        }
    }

    private static func milestones(_ key: IndicatorKey) -> [(Int, String)] {
        switch key {
        case .emergencyFund: [(4_200_000, "1×"), (12_600_000, "3×"), (25_200_000, "6×")]
        case .savingsRatio: [(750_000, "10%"), (1_500_000, "20%")]
        case .instalmentRatio: [(1_125_000, "15%"), (2_250_000, "30%")]
        case .debtToAsset: [(11_175_000, "25%"), (22_350_000, "50%")]
        case .consumerDebt, .protection: []
        }
    }
}
