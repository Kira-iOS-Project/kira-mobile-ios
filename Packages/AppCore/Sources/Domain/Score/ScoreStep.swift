/** The kinds of priority step the engine recommends: the backend's `STEP_KIND` values. */
package enum ScoreStepKind: String, CaseIterable, Hashable, Sendable {
    /** Lunasi the smallest consumer debt ("Utang terkecil dulu"). */
    case payOffDebt = "pay_off_debt"
    /** Ajukan Keringanan for an online loan (debt-free focus). */
    case seekRelief = "seek_relief"
    /** Dana Darurat to the next multiple. */
    case buildEmergencyFund = "build_emergency_fund"
    /** Add basic protection. */
    case addProtection = "add_protection"
    /** Save 10%, then 20%, of income. */
    case raiseSavings = "raise_savings"
    /** Bring instalments down. */
    case lowerInstalments = "lower_instalments"
    /** Bring debt down against assets. */
    case lowerDebtToAsset = "lower_debt_to_asset"
}

/**
 A priority step with the points it is expected to add. The fields beyond `kind` and
 `estimatedGain` are present when the kind uses them.
 */
package struct ScoreStep: Hashable, Sendable {
    /** What to do. */
    package let kind: ScoreStepKind
    /** Score points the step is expected to add. */
    package let estimatedGain: Int
    /** The debt the step is about. */
    package var debtName: String?
    /** What is left of that debt. */
    package var remaining: Int?
    /** The amount today (fund, savings or instalments). */
    package var currentAmount: Int?
    /** The amount the step aims for. */
    package var targetAmount: Int?
    /** The emergency-fund multiple aimed for. */
    package var targetMultiple: Int?
    /** The percent aimed for. */
    package var targetPercent: Int?

    /** What is still missing from the target ("Tambah Rp840.000,00"), never below 0. */
    package var shortfall: Int {
        max((targetAmount ?? 0) - (currentAmount ?? 0), 0)
    }

    /** A step of `kind` adding `estimatedGain` points; set the other fields as the kind needs. */
    package init(kind: ScoreStepKind, estimatedGain: Int) {
        self.kind = kind
        self.estimatedGain = estimatedGain
    }
}
