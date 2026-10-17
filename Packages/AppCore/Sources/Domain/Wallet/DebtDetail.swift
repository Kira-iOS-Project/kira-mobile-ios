/** The engine's debt balance, installment schedule, payment history, and simulated score. */
package struct DebtDetail: Hashable, Sendable {
    package let account: Wallet
    package let originalAmount: Int
    package let paidInstallments: Int
    package let totalInstallments: Int
    package let schedule: [DebtInstallment]
    package let payments: [DebtPayment]
    package let scoreEstimate: DebtScoreEstimate
    package let nextStep: String

    package init(
        account: Wallet, originalAmount: Int, paidInstallments: Int, totalInstallments: Int,
        schedule: [DebtInstallment], payments: [DebtPayment], scoreEstimate: DebtScoreEstimate, nextStep: String = ""
    ) {
        self.account = account
        self.originalAmount = originalAmount
        self.paidInstallments = paidInstallments
        self.totalInstallments = totalInstallments
        self.schedule = schedule
        self.payments = payments
        self.scoreEstimate = scoreEstimate
        self.nextStep = nextStep
    }

    /** The percentage of installments complete, bounded to the visible progress track. */
    package var progress: Double {
        guard totalInstallments > 0 else { return 0 }
        return min(max(Double(paidInstallments) / Double(totalInstallments), 0), 1)
    }
}
