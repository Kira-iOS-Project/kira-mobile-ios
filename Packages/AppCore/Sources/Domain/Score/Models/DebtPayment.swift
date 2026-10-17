/** The score the engine expects once an account is paid off. */
package struct ScoreEstimate: Hashable, Sendable {
    /** The score before. */
    package let before: Int
    /** The score after. */
    package let after: Int

    /** An estimate with every field given. */
    package init(before: Int, after: Int) {
        self.before = before
        self.after = after
    }
}

/** The account the plan moves to after one is paid off. */
package struct NextAccount: Hashable, Sendable {
    /** The account's id. */
    package let id: String
    /** Its name. */
    package let name: String

    /** An account with its id and name. */
    package init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

/** A payment marked on an account: Tandai Sudah Bayar. */
package struct DebtPayment: Hashable, Sendable {
    /** The account paid. */
    package let debtId: String
    /** The account's monthly instalment, which a payoff takes off the month ("Cicilanmu turun"). */
    package let monthlyInstalment: Int
    /** True only for the payment that settled the account: the celebration shows once. */
    package let paidOff: Bool
    /** The account the plan moves to next; nil when the plan has no other account. */
    package let nextAccount: NextAccount?
    /** The expected score; nil unless the account was paid off. */
    package let scoreEstimate: ScoreEstimate?

    /** A payment with every field given. */
    package init(
        debtId: String, monthlyInstalment: Int, paidOff: Bool,
        nextAccount: NextAccount?,
        scoreEstimate: ScoreEstimate?
    ) {
        self.debtId = debtId
        self.monthlyInstalment = monthlyInstalment
        self.paidOff = paidOff
        self.nextAccount = nextAccount
        self.scoreEstimate = scoreEstimate
    }
}
