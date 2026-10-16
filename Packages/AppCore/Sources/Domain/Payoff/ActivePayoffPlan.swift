import Foundation

/** The tag of an account on Rencanaku (SKR-04). */
package enum PlanAccountStatus: String, CaseIterable, Hashable, Sendable {
    /** Sedang dilunasi: the account the plan pays first now. */
    case inProgress = "in_progress"
    /** Berikutnya: an account the plan reaches after the one in progress. */
    case next
    /** Jalan terus: a debt the plan leaves alone. */
    case ongoing
}

/** An account on Rencanaku with its progress and tag. */
package struct PlanAccount: Hashable, Sendable {
    /** The account's id. */
    package let id: String
    /** Its kind. */
    package let kind: DebtKind
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
    package let status: PlanAccountStatus

    /** An account with every field given. */
    package init(
        id: String, kind: DebtKind, name: String, remaining: Int, original: Int, progressPercent: Int,
        monthlyInstalment: Int, annualInterestRate: Double?, dueDay: Int?, status: PlanAccountStatus
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.remaining = remaining
        self.original = original
        self.progressPercent = progressPercent
        self.monthlyInstalment = monthlyInstalment
        self.annualInterestRate = annualInterestRate
        self.dueDay = dueDay
        self.status = status
    }
}

/** The payment to make next, on the account being paid off. */
package struct NextPayment: Hashable, Sendable {
    /** The account's id. */
    package let debtId: String
    /** Its name. */
    package let name: String
    /** The instalment, or what is left when that is less. */
    package let amount: Int
    /** The next due date as `YYYY-MM-DD`; nil without a due day. */
    package let dueDate: String?
    /** Days until then; nil without a due day. */
    package let daysLeft: Int?

    /** A payment with every field given. */
    package init(debtId: String, name: String, amount: Int, dueDate: String?, daysLeft: Int?) {
        self.debtId = debtId
        self.name = name
        self.amount = amount
        self.dueDate = dueDate
        self.daysLeft = daysLeft
    }
}

/** The plan the person made: Rencanaku. */
package struct ActivePayoffPlan: Hashable, Sendable {
    /** The plan's id. */
    package let id: String
    /** Its method. */
    package let method: PayoffMethod
    /** The extra payment it adds each month. */
    package let extraPayment: Int
    /** When the plan was made. */
    package let startedAt: Date
    /** The consumer accounts in the plan's order, then the debts it leaves alone. */
    package let accounts: [PlanAccount]
    /** The next payment; nil when every consumer account is paid. */
    package let nextPayment: NextPayment?

    /** A plan with every field given. */
    package init(
        id: String, method: PayoffMethod, extraPayment: Int, startedAt: Date, accounts: [PlanAccount],
        nextPayment: NextPayment?
    ) {
        self.id = id
        self.method = method
        self.extraPayment = extraPayment
        self.startedAt = startedAt
        self.accounts = accounts
        self.nextPayment = nextPayment
    }

    /** The consumer accounts the plan pays, in order. */
    package var consumerAccounts: [PlanAccount] { accounts.filter { $0.status != .ongoing } }

    /** The debts the plan leaves alone. */
    package var ongoingAccounts: [PlanAccount] { accounts.filter { $0.status == .ongoing } }

    /** The account being paid off now; nil when every consumer account is paid. */
    package var focus: PlanAccount? { accounts.first { $0.status == .inProgress } }

    /** The plan's own progress, 0 to 100: what is paid of the consumer accounts' original balances. */
    package var progressPercent: Int {
        let original = consumerAccounts.reduce(0) { $0 + $1.original }
        guard original > 0 else { return 0 }
        let remaining = consumerAccounts.reduce(0) { $0 + $1.remaining }
        return max(0, min(100, (original - remaining) * 100 / original))
    }
}
