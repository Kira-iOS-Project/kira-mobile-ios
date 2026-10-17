import APIClient
import Domain

/** The score's answers in the Domain's values (`GET /score`, `PUT /health-check`, an indicator). */
extension ScoreReport {
    /** The report the engine sent; the next check is the WIB day it names. */
    init(_ dto: ScoreReportDTO) throws {
        self.init(
            score: dto.score, band: dto.band, computedAt: dto.computedAt,
            nextCheckOn: try Bridge.day(dto.nextCheckOn).date)
        delta = dto.delta
        groups = try dto.groups.map { GroupScore(group: try Bridge.value($0.group), points: $0.points, band: $0.band) }
        indicators = try dto.indicators.map(ScoreIndicator.init)
        steps = try dto.steps.map(ScoreStep.init)
        cappedByConsumerDebt = dto.cappedByConsumerDebt
    }
}

extension ScoreIndicator {
    /** One indicator with its measure. */
    init(_ dto: IndicatorDTO) throws {
        self.init(
            key: dto.key, group: try Bridge.value(dto.group), points: dto.points, band: dto.band,
            measure: IndicatorMeasure(dto.measure))
    }
}

extension IndicatorMeasure {
    /** The measure; the emergency-fund target is a whole multiple (6× to 15×). */
    init(_ dto: IndicatorMeasureDTO) {
        switch dto {
        case .emergencyFund(let ratio, let liquid, let essential, let multiple, let amount):
            self = .emergencyFund(
                ratio: ratio, liquid: liquid, essential: essential, targetMultiple: Int(multiple.rounded()),
                targetAmount: amount)
        case .savingsRatio(let percent, let savings, let income):
            self = .savingsRatio(percent: percent, monthlySavings: savings, income: income)
        case .instalmentRatio(let percent, let instalments, let income):
            self = .instalmentRatio(percent: percent, monthlyInstalments: instalments, income: income)
        case .consumerDebt(let platforms, let anyLate, let anyOverdue):
            self = .consumerDebt(platforms: platforms, anyLate: anyLate, anyOverdue: anyOverdue)
        case .debtToAsset(let percent, let debt, let assets):
            self = .debtToAsset(percent: percent, totalDebt: debt, totalAssets: assets)
        case .protection(let health, let income):
            self = .protectionCover(health: health, income: income)
        }
    }
}

extension ScoreStep {
    /** A priority step with the fields its kind uses. */
    init(_ dto: ScoreStepDTO) throws {
        self.init(kind: try Bridge.value(dto.kind), estimatedGain: dto.estimatedGain)
        debtName = dto.debtName
        remaining = dto.remaining
        currentAmount = dto.currentAmount
        targetAmount = dto.targetAmount
        targetMultiple = dto.targetMultiple
        targetPercent = dto.targetPercent
    }
}

extension IndicatorDetail {
    /** One indicator in full: its ladder, the next rung and the milestones. */
    init(_ dto: IndicatorDetailDTO) throws {
        self.init(
            indicator: try ScoreIndicator(dto.indicator),
            ladder: dto.ladder.map {
                LadderRung(
                    points: $0.points, lower: $0.lower, upper: $0.upper, amountLower: $0.amountLower,
                    amountUpper: $0.amountUpper, isCurrent: $0.isCurrent)
            },
            nextRung: dto.nextRung.map {
                NextRung(points: $0.points, amountNeeded: $0.amountNeeded, scoreFrom: $0.scoreFrom, scoreTo: $0.scoreTo)
            },
            milestones: dto.milestones.map { Milestone(amount: $0.amount, label: $0.label) })
    }
}
