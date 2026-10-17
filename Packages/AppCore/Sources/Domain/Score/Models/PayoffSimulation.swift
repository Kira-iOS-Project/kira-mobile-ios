/** One consumer account in a simulated plan, in the order the plan pays. */
package struct PayoffAccount: Hashable, Sendable {
    /** The account's id. */
    package let id: String
    /** Its kind. */
    package let kind: DebtKind
    /** Its name ("Paylater A"). */
    package let name: String
    /** What is left to pay. */
    package let remaining: Int
    /** The monthly instalment. */
    package let monthlyInstalment: Int
    /** The day it is paid off, on its due day; nil when it never is or the due day is unknown. */
    package let payoffDate: CalendarDay?
    /** 1 for the account the plan pays first. */
    package let position: Int
    /** The month it is paid off, as `YYYY-MM`; nil when it never is. */
    package let payoffMonth: String?

    /** An account with every field given. */
    package init(
        id: String, kind: DebtKind, name: String, remaining: Int, monthlyInstalment: Int,
        position: Int, payoffMonth: String?, 
        payoffDate: CalendarDay? = nil
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.remaining = remaining
        self.monthlyInstalment = monthlyInstalment
        self.payoffDate = payoffDate
        self.position = position
        self.payoffMonth = payoffMonth
    }
}

/** A debt the plan leaves alone: a vehicle, a home or a family loan. */
package struct ProductiveDebt: Hashable, Sendable {
    /** The account's id. */
    package let id: String
    /** Its kind. */
    package let kind: DebtKind
    /** Its name ("Cicilan Motor"). */
    package let name: String
    /** What is left to pay. */
    package let remaining: Int
    /** The month it is paid off at its instalment, as `YYYY-MM`; nil when unknown. */
    package let payoffMonth: String?
    /** The day it is paid off; nil when unknown. */
    package let payoffDate: CalendarDay?

    /** A debt with every field given. */
    package init(
        id: String, kind: DebtKind, name: String, remaining: Int, payoffMonth: String? = nil,
        payoffDate: CalendarDay? = nil
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.remaining = remaining
        self.payoffMonth = payoffMonth
        self.payoffDate = payoffDate
    }
}

/** The chosen method set against the other one (SKR-03c). */
package struct PayoffComparison: Hashable, Sendable {
    /** The interest the chosen method saves; negative when the other costs less; nil without a known rate. */
    package let interestSaved: Int?
    /** Months later the other method pays off its first account; negative when sooner. */
    package let firstPayoffMonthsLater: Int?

    /** A comparison with every field given. */
    package init(interestSaved: Int?, firstPayoffMonthsLater: Int?) {
        self.interestSaved = interestSaved
        self.firstPayoffMonthsLater = firstPayoffMonthsLater
    }




}

/** A simulated plan: what the screen shows for a method and an extra payment. */
package struct PayoffSimulation: Hashable, Sendable {
    /** The method simulated. */
    package let method: PayoffMethod
    /** The extra payment simulated. */
    package let extraPayment: Int
    /** The most the extra payment may be: the money left this payday period. */
    package let maxExtraPayment: Int
    /** An account has no interest rate, which the plan counts as 0%. */
    package let hasUnknownRate: Bool
    /** The consumer accounts in the plan's order. */
    package let accounts: [PayoffAccount]
    /** The debts the plan leaves alone. */
    package let productive: [ProductiveDebt]
    /** The month the last account is paid off, as `YYYY-MM`; nil unless all are. */
    package let allPaidMonth: String?
    /** The day the last account is paid off; nil unless all are, or when its due day is unknown. */
    package let allPaidDate: CalendarDay?
    /** Against the other method; nil without a consumer debt. */
    package let comparison: PayoffComparison?

    /** A simulation with every field given. */
    package init(
        method: PayoffMethod, extraPayment: Int, maxExtraPayment: Int, hasUnknownRate: Bool,
        accounts: [PayoffAccount], productive: [ProductiveDebt], 
        allPaidMonth: String?, comparison: PayoffComparison?, allPaidDate: CalendarDay? = nil
    ) {
        self.method = method
        self.extraPayment = extraPayment
        self.maxExtraPayment = maxExtraPayment
        self.hasUnknownRate = hasUnknownRate
        self.accounts = accounts
        self.productive = productive
        self.allPaidMonth = allPaidMonth
        self.comparison = comparison
        self.allPaidDate = allPaidDate
    }
}
