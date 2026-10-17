import APIClient
import Domain

/** Beranda's answer in the Domain's values (`GET /home`). */
extension HomeOverview {
    /** Today's Beranda; the wallet item of the checklist is left out (no wallets yet). */
    init(_ dto: HomeDTO) throws {
        self.init(
            variant: try Bridge.value(dto.variant), today: try Bridge.day(dto.today).date,
            displayName: dto.displayName, hideBalances: dto.hideBalances, period: try Bridge.period(dto.period),
            money: dto.money.map {
                PeriodMoney(
                    income: $0.income, spent: $0.spent, remaining: $0.remaining, perDay: $0.perDay,
                    spentPercent: $0.spentPercent)
            },
            step: try dto.step.map(ScoreStep.init),
            stepPosition: dto.stepPosition.map { StepPosition(index: $0.index, total: $0.total) },
            score: dto.score.map {
                ScoreSummary(score: $0.score, band: $0.band, delta: $0.delta, isInitial: $0.isInitial)
            },
            weeklySummary: try dto.weeklySummary.map {
                DayRange(first: try Bridge.day($0.first), last: try Bridge.day($0.last))
            },
            checklist: dto.checklist.map {
                FirstStepsChecklist(
                    healthCheck: $0.healthCheck, firstTransaction: $0.firstTransaction, paydaySet: $0.paydaySet)
            },
            debtPlan: dto.debtPlan.map {
                DebtPlanProgress(paidOff: $0.paidOff, total: $0.total, remaining: $0.remaining, percent: $0.percent)
            },
            microTarget: try dto.microTarget.map {
                MicroTarget(kind: try Bridge.value($0.kind), current: $0.current, target: $0.target)
            })
    }
}

extension HealthCheckInputDTO {
    /** The body of `PUT /health-check` from the quiz's answers. */
    init(_ answers: HealthCheckAnswers) throws {
        self.init()
        netMonthlyIncome = answers.netMonthlyIncome
        payday = PaydayDTO(day: answers.payday.day, endOfMonth: answers.payday.isEndOfMonth)
        essentialMonthlyExpenses = answers.essentialMonthlyExpenses
        debts = try answers.debts.map {
            HealthCheckDebtDTO(
                kind: try Bridge.value($0.kind), name: $0.name, remaining: $0.remaining,
                monthlyInstalment: $0.monthlyInstalment, remainingTenorMonths: $0.remainingTenorMonths,
                annualInterestRate: $0.annualInterestRate, dueDay: $0.dueDay)
        }
        emergencyFund = answers.emergencyFund
        monthlySavings = answers.monthlySavings
        otherAssets = answers.otherAssets
        propertyAssets = answers.propertyAssets
        dependents = answers.dependents
        maritalStatus = try answers.maritalStatus.map { try Bridge.value($0) }
        protections = try Protection.allCases.filter(answers.protections.contains).map { try Bridge.value($0) }
    }
}
