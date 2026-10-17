import APIClient
import Domain

/** The simulation's answer in the Domain's values (`POST /payoff/simulate`). */
extension PayoffSimulation {
    /** The plan the engine sent. */
    init(_ dto: PayoffPlanDTO) throws {
        self.init(
            method: try Bridge.value(dto.method), extraPayment: dto.extraPayment, maxExtraPayment: dto.maxExtraPayment,
            monthlyBudget: dto.monthlyBudget, hasUnknownRate: dto.hasUnknownRate,
            accounts: try dto.accounts.map(PayoffAccount.init), productive: try dto.productive.map(ProductiveDebt.init),
            totalInterest: dto.totalInterest, allPaidMonths: dto.allPaidMonths, allPaidMonth: dto.allPaidMonth,
            comparison: try dto.comparison.map(PayoffComparison.init), allPaidDate: try dto.allPaidDate.map(Bridge.day))
    }
}

extension PayoffAccount {
    /** One consumer account. */
    init(_ dto: PayoffAccountDTO) throws {
        self.init(
            id: dto.id, kind: try Bridge.value(dto.kind), name: dto.name, remaining: dto.remaining,
            monthlyInstalment: dto.monthlyInstalment, annualInterestRate: dto.annualInterestRate,
            position: dto.position, months: dto.months, payoffMonth: dto.payoffMonth, interest: dto.interest,
            payoffDate: try dto.payoffDate.map(Bridge.day))
    }
}

extension ProductiveDebt {
    /** One debt the plan leaves alone. */
    init(_ dto: PayoffProductiveDebtDTO) throws {
        self.init(
            id: dto.id, kind: try Bridge.value(dto.kind), name: dto.name, remaining: dto.remaining,
            monthlyInstalment: dto.monthlyInstalment, payoffMonth: dto.payoffMonth,
            payoffDate: try dto.payoffDate.map(Bridge.day))
    }
}

extension PayoffComparison {
    /** The chosen method against the other. */
    init(_ dto: PayoffComparisonDTO) throws {
        self.init(
            otherMethod: try Bridge.value(dto.otherMethod), interestSaved: dto.interestSaved,
            firstPayoffMonthsLater: dto.firstPayoffMonthsLater)
    }
}
