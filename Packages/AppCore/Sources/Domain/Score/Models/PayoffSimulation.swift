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
    /** The interest a year in percent; nil when the person has not said. */
    package let annualInterestRate: Double?
    /** The day of the month its instalment is due; nil when the person has not said. */
    package let dueDay: Int?
    /** 1 for the account the plan pays first. */
    package let position: Int
    /** Months until it is paid off, this month counted as 1; nil when it never is. */
    package let months: Int?
    /** The month it is paid off, as `YYYY-MM`; nil when it never is. */
    package let payoffMonth: String?
    /** The interest it costs until then; nil when it is never paid off. */
    package let interest: Int?

    /** An account with every field given. */
    package init(
        id: String, kind: DebtKind, name: String, remaining: Int, monthlyInstalment: Int,
        annualInterestRate: Double?, position: Int, months: Int?, payoffMonth: String?, interest: Int?,
        dueDay: Int? = nil
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.remaining = remaining
        self.monthlyInstalment = monthlyInstalment
        self.annualInterestRate = annualInterestRate
        self.dueDay = dueDay
        self.position = position
        self.months = months
        self.payoffMonth = payoffMonth
        self.interest = interest
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
    /** The monthly instalment. */
    package let monthlyInstalment: Int

    /** A debt with every field given. */
    package init(id: String, kind: DebtKind, name: String, remaining: Int, monthlyInstalment: Int) {
        self.id = id
        self.kind = kind
        self.name = name
        self.remaining = remaining
        self.monthlyInstalment = monthlyInstalment
    }
}

/** The chosen method set against the other one (SKR-03c). */
package struct PayoffComparison: Hashable, Sendable {
    /** The method it is set against. */
    package let otherMethod: PayoffMethod
    /** The interest the chosen method saves; negative when the other costs less; nil without a known rate. */
    package let interestSaved: Int?
    /** Months later the other method pays off its first account; negative when sooner. */
    package let firstPayoffMonthsLater: Int?

    /** A comparison with every field given. */
    package init(otherMethod: PayoffMethod, interestSaved: Int?, firstPayoffMonthsLater: Int?) {
        self.otherMethod = otherMethod
        self.interestSaved = interestSaved
        self.firstPayoffMonthsLater = firstPayoffMonthsLater
    }

    /** What the chosen method does to the interest, in rupiah and unsigned. */
    package enum InterestOutcome: Hashable, Sendable {
        /** The chosen method costs this much less interest. */
        case saves(Int)
        /** The chosen method costs this much more interest. */
        case costs(Int)
        /** Both cost the same. */
        case same
        /** No account has a known rate, so there is nothing to compare. */
        case unknown
    }

    /** What the chosen method does to the first payoff, in whole months and unsigned. */
    package enum FirstPayoffOutcome: Hashable, Sendable {
        /** The chosen method pays off its first account this many months sooner. */
        case sooner(Int)
        /** The chosen method pays off its first account this many months later. */
        case later(Int)
        /** Both pay off the first account in the same month. */
        case same
        /** The other method never pays off an account, or there is none. */
        case unknown
    }

    /** The interest the chosen method saves, costs or leaves as it is. */
    package var interest: InterestOutcome {
        guard let saved = interestSaved else { return .unknown }
        if saved > 0 { return .saves(saved) }
        if saved < 0 { return .costs(-saved) }
        return .same
    }

    /** The first payoff against the other method's; a positive `firstPayoffMonthsLater` is sooner for this one. */
    package var firstPayoff: FirstPayoffOutcome {
        guard let later = firstPayoffMonthsLater else { return .unknown }
        if later > 0 { return .sooner(later) }
        if later < 0 { return .later(-later) }
        return .same
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
    /** What the plan pays each month. */
    package let monthlyBudget: Int
    /** An account has no interest rate, which the plan counts as 0%. */
    package let hasUnknownRate: Bool
    /** The consumer accounts in the plan's order. */
    package let accounts: [PayoffAccount]
    /** The debts the plan leaves alone. */
    package let productive: [ProductiveDebt]
    /** The interest of every account together; nil unless all are paid off. */
    package let totalInterest: Int?
    /** Months until the last account is paid off; nil unless all are. */
    package let allPaidMonths: Int?
    /** The month the last account is paid off, as `YYYY-MM`; nil unless all are. */
    package let allPaidMonth: String?
    /** Against the other method; nil without a consumer debt. */
    package let comparison: PayoffComparison?

    /** A simulation with every field given. */
    package init(
        method: PayoffMethod, extraPayment: Int, maxExtraPayment: Int, monthlyBudget: Int, hasUnknownRate: Bool,
        accounts: [PayoffAccount], productive: [ProductiveDebt], totalInterest: Int?, allPaidMonths: Int?,
        allPaidMonth: String?, comparison: PayoffComparison?
    ) {
        self.method = method
        self.extraPayment = extraPayment
        self.maxExtraPayment = maxExtraPayment
        self.monthlyBudget = monthlyBudget
        self.hasUnknownRate = hasUnknownRate
        self.accounts = accounts
        self.productive = productive
        self.totalInterest = totalInterest
        self.allPaidMonths = allPaidMonths
        self.allPaidMonth = allPaidMonth
        self.comparison = comparison
    }
}
