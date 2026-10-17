import Foundation

/** The tag of an account on Rencanaku (SKR-04). */
package enum PlanAccountStatus: String, CaseIterable, Hashable, Sendable {
    /** Sedang Dilunasi: the account the plan pays first now. */
    case inProgress = "in_progress"
    /** Berikutnya: an account the plan reaches after the one in progress. */
    case next
    /** Jalan Terus: a debt the plan leaves alone, paid as usual. */
    case ongoing
    /** Lunas: an account the plan has already settled. */
    case paidOff = "paid_off"
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
    /** Its tag. */
    package let status: PlanAccountStatus
    /** The month (`YYYY-MM`) the plan pays it off, or its own instalments end; nil when it cannot be known. */
    package let payoffMonth: String?
    /** The due date (`YYYY-MM-DD`) of its last payment; nil without a due day. */
    package let payoffDate: String?
    /** For an account that comes next, the month (`YYYY-MM`) the plan reaches it; nil otherwise. */
    package let startMonth: String?

    /** An account with every field given. */
    package init(
        id: String, kind: DebtKind, name: String, remaining: Int, original: Int, progressPercent: Int,
        monthlyInstalment: Int, status: PlanAccountStatus,
        payoffMonth: String?, payoffDate: String?, startMonth: String?
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.remaining = remaining
        self.original = original
        self.progressPercent = progressPercent
        self.monthlyInstalment = monthlyInstalment
        self.status = status
        self.payoffMonth = payoffMonth
        self.payoffDate = payoffDate
        self.startMonth = startMonth
    }

    /** What is paid so far of the original balance. */
    package var paid: Int { max(0, original - remaining) }
}

/** The payment to make next, on the account being paid off. */
package struct NextPayment: Hashable, Sendable {
    /** The account's id. */
    package let debtId: String
    /** Its name. */
    package let name: String
    /** The whole payment: the instalment and the extra. */
    package let amount: Int
    /** The instalment part (Cicilan). */
    package let instalment: Int
    /** The plan's extra part (Tambahan); 0 without one. */
    package let extra: Int
    /** The next due date as `YYYY-MM-DD`; nil without a due day. */
    package let dueDate: String?
    /** Days until then; nil without a due day. */
    package let daysLeft: Int?

    /** A payment with every field given. */
    package init(
        debtId: String, name: String, amount: Int, instalment: Int, extra: Int, dueDate: String?, daysLeft: Int?
    ) {
        self.debtId = debtId
        self.name = name
        self.amount = amount
        self.instalment = instalment
        self.extra = extra
        self.dueDate = dueDate
        self.daysLeft = daysLeft
    }
}

/** When the account in progress is paid off, as the API says it: no date is worked out on the device. */
package enum PayoffCountdown: Hashable, Sendable {
    /** The next payment settles it, due in this many days (0 is today). */
    case days(Int)
    /** On this due date (`YYYY-MM-DD`). */
    case date(String)
    /** In this month (`YYYY-MM`), the account having no due day. */
    case month(String)
    /** The plan cannot say. */
    case unknown
}

/** The plan the person made: Rencanaku. */
package struct ActivePayoffPlan: Hashable, Sendable {
    /** Its method. */
    package let method: PayoffMethod
    /** When the plan was made. */
    package let startedAt: Date
    /** Every account in the plan's order: the consumer accounts, then the debts it leaves alone. */
    package let accounts: [PlanAccount]
    /** The next payment; nil when every consumer account is paid. */
    package let nextPayment: NextPayment?

    /** A plan with every field given. */
    package init(
        method: PayoffMethod, startedAt: Date, accounts: [PlanAccount],
        nextPayment: NextPayment?
    ) {
        self.method = method
        self.startedAt = startedAt
        self.accounts = accounts
        self.nextPayment = nextPayment
    }

    /** The account being paid off now; nil when every consumer account is paid. */
    package var focus: PlanAccount? { accounts.first { $0.status == .inProgress } }

    /** The account's place in the plan, from 1 ("Akun 1 dari 3"); nil when it is not in the plan. */
    package func position(of debtId: String) -> Int? {
        accounts.firstIndex { $0.id == debtId }.map { $0 + 1 }
    }

    /** The account `debtId`; nil when it is not in the plan. */
    package func account(_ debtId: String) -> PlanAccount? {
        accounts.first { $0.id == debtId }
    }

    /**
     When the account in progress is paid off: in the next payment's days left when that payment
     settles it, else on its last due date, else in its month.
     */
    package var focusCountdown: PayoffCountdown {
        guard let focus else { return .unknown }
        if let next = nextPayment, next.debtId == focus.id, next.amount >= focus.remaining, let left = next.daysLeft {
            return .days(max(0, left))
        }
        if let date = focus.payoffDate { return .date(date) }
        if let month = focus.payoffMonth { return .month(month) }
        return .unknown
    }
}
