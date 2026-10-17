/** The payoff plan as `POST /api/payoff/simulate` reports it (SKR-03). */

/** The order a plan pays in: the smallest balance first, or the highest interest first. */
package enum PayoffMethodDTO: String, CaseIterable, Sendable {
    /** Snowball: the smallest balance first. */
    case snowball
    /** Avalanche: the highest interest first. */
    case avalanche
}

/** The tag of an account on Rencanaku: Sedang dilunasi, Berikutnya, Jalan terus. */
package enum PayoffAccountStatusDTO: String, CaseIterable, Sendable {
    /** Sedang dilunasi. */
    case inProgress = "in_progress"
    /** Berikutnya. */
    case next
    /** Jalan terus. */
    case ongoing
    /** Lunas: a paid account stays in the plan. */
    case paidOff = "paid_off"
}

/** One consumer account in a simulated plan's order. */
package struct PayoffAccountDTO: Hashable, Sendable {
    /** The account's id. */
    package let id: String
    /** Its kind. */
    package let kind: DebtKindDTO
    /** Its name ("Paylater A"). */
    package let name: String
    /** What is left to pay. */
    package let remaining: Int
    /** The monthly instalment. */
    package let monthlyInstalment: Int
    /** 1 for the account the plan pays first. */
    package let position: Int
    /** The month it is paid off (`YYYY-MM`); nil when it never is. */
    package let payoffMonth: String?
    /** The day it is paid off, on its due day (`YYYY-MM-DD`); nil when it never is or the day is unknown. */
    package let payoffDate: String?

    init(_ account: Components.Schemas.PayoffAccount) throws {
        id = account.id
        kind = try bridged(account.kind)
        name = account.name
        remaining = account.remaining
        monthlyInstalment = account.monthlyInstalment
        position = account.position
        payoffMonth = account.payoffMonth
        payoffDate = account.payoffDate
    }
}

/** A debt the plan leaves alone: home, vehicle or family loans. */
package struct PayoffProductiveDebtDTO: Hashable, Sendable {
    /** The account's id. */
    package let id: String
    /** Its kind. */
    package let kind: DebtKindDTO
    /** Its name ("Cicilan Motor"). */
    package let name: String
    /** What is left to pay. */
    package let remaining: Int
    /** The month it is paid off at its instalment (`YYYY-MM`); nil when unknown. */
    package let payoffMonth: String?
    /** The day it is paid off (`YYYY-MM-DD`); nil when unknown. */
    package let payoffDate: String?

    init(_ debt: Components.Schemas.PayoffProductiveDebt) throws {
        id = debt.id
        kind = try bridged(debt.kind)
        name = debt.name
        remaining = debt.remaining
        payoffMonth = debt.payoffMonth
        payoffDate = debt.payoffDate
    }
}

/** The chosen method against the other one. */
package struct PayoffComparisonDTO: Hashable, Sendable {
    /** The interest the chosen method saves; negative when the other costs less; nil without a known rate. */
    package let interestSaved: Int?
    /** Months later the other method pays off its first account; negative when sooner. */
    package let firstPayoffMonthsLater: Int?

    init(_ comparison: Components.Schemas.PayoffComparison) throws {
        interestSaved = comparison.interestSaved
        firstPayoffMonthsLater = comparison.firstPayoffMonthsLater
    }
}

/** A simulated plan. */
package struct PayoffPlanDTO: Hashable, Sendable {
    /** The method simulated. */
    package let method: PayoffMethodDTO
    /** The extra payment simulated. */
    package let extraPayment: Int
    /** The most the extra payment may be: the money left this payday period. */
    package let maxExtraPayment: Int
    /** An account has no interest rate, which the plan counts as 0%. */
    package let hasUnknownRate: Bool
    /** The consumer accounts in the plan's order. */
    package let accounts: [PayoffAccountDTO]
    /** The debts the plan leaves alone. */
    package let productive: [PayoffProductiveDebtDTO]
    /** The month the last account is paid off (`YYYY-MM`); nil unless all are. */
    package let allPaidMonth: String?
    /** The day the last account is paid off (`YYYY-MM-DD`); nil unless all are, or the day is unknown. */
    package let allPaidDate: String?
    /** Against the other method; nil without a consumer debt. */
    package let comparison: PayoffComparisonDTO?

    init(_ plan: Components.Schemas.PayoffPlan) throws {
        method = try bridged(plan.method)
        extraPayment = plan.extraPayment
        maxExtraPayment = plan.maxExtraPayment
        hasUnknownRate = plan.hasUnknownRate
        accounts = try plan.accounts.map(PayoffAccountDTO.init)
        productive = try plan.productive.map(PayoffProductiveDebtDTO.init)
        allPaidMonth = plan.allPaidMonth
        allPaidDate = plan.allPaidDate
        comparison = try plan.comparison.map(PayoffComparisonDTO.init)
    }
}
