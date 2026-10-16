import Foundation

/**
 One step the score engine proposes, in its order (smallest consumer debt, then the emergency fund,
 protection, savings, instalments, debt to assets). The numbers come from the engine; the app only
 writes the sentence around them.
 */
package struct ScoreStep: Equatable, Sendable {
    /** What the step asks for: the backend's `STEP_KIND` values. */
    package enum Kind: String, CaseIterable, Sendable {
        case payOffDebt = "pay_off_debt"
        case buildEmergencyFund = "build_emergency_fund"
        case addProtection = "add_protection"
        case raiseSavings = "raise_savings"
        case lowerInstalments = "lower_instalments"
        case lowerDebtToAsset = "lower_debt_to_asset"
        /** For a debt-free focus with an online loan: ask that lender for relief. */
        case seekRelief = "seek_relief"
    }

    package let kind: Kind
    /** Kira Score points the step adds once done. */
    package let estimatedGain: Int
    package let debtName: String?
    package let remaining: Decimal?
    package let currentAmount: Decimal?
    package let targetAmount: Decimal?
    package let targetMultiple: Int?
    package let targetPercent: Int?

    package init(
        kind: Kind, estimatedGain: Int, debtName: String? = nil, remaining: Decimal? = nil,
        currentAmount: Decimal? = nil, targetAmount: Decimal? = nil, targetMultiple: Int? = nil,
        targetPercent: Int? = nil
    ) {
        self.kind = kind
        self.estimatedGain = estimatedGain
        self.debtName = debtName
        self.remaining = remaining
        self.currentAmount = currentAmount
        self.targetAmount = targetAmount
        self.targetMultiple = targetMultiple
        self.targetPercent = targetPercent
    }

    /** How much more the step needs: the target less the current amount, never below zero. */
    package var shortfall: Decimal {
        max((targetAmount ?? 0) - (currentAmount ?? 0), 0)
    }
}
