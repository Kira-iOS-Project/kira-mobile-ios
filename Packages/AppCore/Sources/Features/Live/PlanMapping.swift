import APIClient
import Domain

/** Rencanaku's answers in the Domain's values. */
extension ActivePayoffPlan {
    /** The plan the engine sent. */
    init(_ dto: ActivePlanDTO) throws {
        self.init(
            id: dto.id, method: try Bridge.value(dto.method), extraPayment: dto.extraPayment, startedAt: dto.startedAt,
            accounts: try dto.accounts.map(PlanAccount.init), nextPayment: dto.nextPayment.map(NextPayment.init))
    }
}

extension PlanAccount {
    /** One account of the plan. */
    init(_ dto: PlanAccountDTO) throws {
        self.init(
            id: dto.id, kind: try Bridge.value(dto.kind), name: dto.name, remaining: dto.remaining,
            original: dto.original, progressPercent: dto.progressPercent, monthlyInstalment: dto.monthlyInstalment,
            annualInterestRate: dto.annualInterestRate, dueDay: dto.dueDay, status: try Bridge.value(dto.status))
    }
}

extension NextPayment {
    /** The payment to make next. */
    init(_ dto: NextPaymentDTO) {
        self.init(
            debtId: dto.debtId, name: dto.name, amount: dto.amount, dueDate: dto.dueDate, daysLeft: dto.daysLeft)
    }
}

extension DebtPayment {
    /** A payment as the API settled it. */
    init(_ dto: PaymentResultDTO) {
        self.init(
            debtId: dto.debtId, paid: dto.paid, remaining: dto.remaining, progressPercent: dto.progressPercent,
            paidOff: dto.paidOff, nextAccount: dto.nextAccount.map { NextAccount(id: $0.id, name: $0.name) },
            scoreEstimate: dto.scoreEstimate.map {
                ScoreEstimate(
                    before: $0.before, after: $0.after, consumerDebtBefore: $0.consumerDebtBefore,
                    consumerDebtAfter: $0.consumerDebtAfter)
            })
    }
}
