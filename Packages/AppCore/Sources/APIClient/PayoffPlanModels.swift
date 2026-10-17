import Foundation

/** Rencanaku (SKR-04) and the payment that settles an account (SKR-05), as the API reports them. */

/** An account on Rencanaku with its progress and tag. */
package struct PlanAccountDTO: Hashable, Sendable {
    /** The account's id. */
    package let id: String
    /** Its kind. */
    package let kind: DebtKindDTO
    /** Its name. */
    package let name: String
    /** What is left to pay. */
    package let remaining: Int
    /** The balance when the account was added. */
    package let original: Int
    /** Paid so far over the original balance, 0 to 100. */
    package let progressPercent: Int
    /** The monthly instalment. */
    package let monthlyInstalment: Int
    /** The interest a year in percent; nil when unknown. */
    package let annualInterestRate: Double?
    /** The day of the month it is due; nil when unknown. */
    package let dueDay: Int?
    /** Its tag. */
    package let status: PayoffAccountStatusDTO
    /** The month (`YYYY-MM`) it is paid off; nil when it cannot be known. */
    package let payoffMonth: String?
    /** The due date (`YYYY-MM-DD`) of its last payment; nil without a due day. */
    package let payoffDate: String?
    /** For the account that comes next, the month (`YYYY-MM`) the plan reaches it. */
    package let startMonth: String?

    init(_ account: Components.Schemas.PayoffPlanAccount) throws {
        id = account.id
        kind = try bridged(account.kind)
        name = account.name
        remaining = account.remaining
        original = account.original
        progressPercent = account.progressPercent
        monthlyInstalment = account.monthlyInstalment
        annualInterestRate = account.annualInterestRate
        dueDay = account.dueDay
        status = try bridged(account.status)
        payoffMonth = account.payoffMonth
        payoffDate = account.payoffDate
        startMonth = account.startMonth
    }
}

/** The payment to make next on the account being paid off. */
package struct NextPaymentDTO: Hashable, Sendable {
    /** The account's id. */
    package let debtId: String
    /** Its name. */
    package let name: String
    /** The whole payment: the instalment and the extra. */
    package let amount: Int
    /** The instalment part. */
    package let instalment: Int
    /** The plan's extra part. */
    package let extra: Int
    /** The next due date (`YYYY-MM-DD`); nil without a due day. */
    package let dueDate: String?
    /** Days until then; nil without a due day. */
    package let daysLeft: Int?

    init(_ payment: Components.Schemas.PayoffNextPayment) {
        debtId = payment.debtId
        name = payment.name
        amount = payment.amount
        instalment = payment.instalment
        extra = payment.extra
        dueDate = payment.dueDate
        daysLeft = payment.daysLeft
    }
}

/** The active plan, Rencanaku. */
package struct ActivePlanDTO: Hashable, Sendable {
    /** The plan's id. */
    package let id: String
    /** Its method. */
    package let method: PayoffMethodDTO
    /** The extra payment it adds each month. */
    package let extraPayment: Int
    /** When the plan was made. */
    package let startedAt: Date
    /** The consumer accounts in the plan's order, then the debts it leaves alone. */
    package let accounts: [PlanAccountDTO]
    /** The next payment; nil when every consumer account is paid. */
    package let nextPayment: NextPaymentDTO?

    init(_ plan: Components.Schemas.PayoffActivePlan) throws {
        id = plan.id
        method = try bridged(plan.method)
        extraPayment = plan.extraPayment
        startedAt = plan.startedAt
        accounts = try plan.accounts.map(PlanAccountDTO.init)
        nextPayment = plan.nextPayment.map(NextPaymentDTO.init)
    }
}

/** The score the engine expects once an account is paid off. */
package struct ScoreEstimateDTO: Hashable, Sendable {
    /** The score before. */
    package let before: Int
    /** The score after. */
    package let after: Int
    /** The consumer-debt points before. */
    package let consumerDebtBefore: Int
    /** The consumer-debt points after. */
    package let consumerDebtAfter: Int

    init(_ estimate: Components.Schemas.PayoffScoreEstimate) {
        before = estimate.before
        after = estimate.after
        consumerDebtBefore = estimate.consumerDebtBefore
        consumerDebtAfter = estimate.consumerDebtAfter
    }
}

/** The account the plan moves to after one is paid off. */
package struct NextAccountDTO: Hashable, Sendable {
    /** The account's id. */
    package let id: String
    /** Its name. */
    package let name: String
}

/** A payment marked on an account (Tandai Sudah Bayar). */
package struct PaymentResultDTO: Hashable, Sendable {
    /** The account paid. */
    package let debtId: String
    /** What was paid. */
    package let paid: Int
    /** What is left. */
    package let remaining: Int
    /** The account's monthly instalment. */
    package let monthlyInstalment: Int
    /** Paid so far over the original balance, 0 to 100. */
    package let progressPercent: Int
    /** True only for the payment that settled the account: show the celebration once. */
    package let paidOff: Bool
    /** The account the plan moves to next; nil when the plan has no other account. */
    package let nextAccount: NextAccountDTO?
    /** The expected score; nil unless the account was paid off. */
    package let scoreEstimate: ScoreEstimateDTO?

    init(_ result: Components.Schemas.DebtPaymentResult) {
        debtId = result.debtId
        paid = result.paid
        remaining = result.remaining
        monthlyInstalment = result.monthlyInstalment
        progressPercent = result.progressPercent
        paidOff = result.paidOff
        nextAccount = result.nextAccount.map { NextAccountDTO(id: $0.id, name: $0.name) }
        scoreEstimate = result.scoreEstimate.map(ScoreEstimateDTO.init)
    }
}
