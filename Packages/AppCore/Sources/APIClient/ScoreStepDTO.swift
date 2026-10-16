/** A priority step the engine recommends (Tiga Langkah Prioritas, Langkah Berikutnya). */

/** What the step asks for. */
package enum StepKindDTO: String, CaseIterable, Sendable {
    /** Lunasi the smallest consumer debt ("Utang terkecil dulu"). */
    case payOffDebt = "pay_off_debt"
    /** Ajukan Keringanan for an online loan. */
    case seekRelief = "seek_relief"
    /** Dana Darurat to the next multiple. */
    case buildEmergencyFund = "build_emergency_fund"
    /** Add health or income cover. */
    case addProtection = "add_protection"
    /** Menabung 10%, then 20%, of income. */
    case raiseSavings = "raise_savings"
    /** Bring instalments under the next bound. */
    case lowerInstalments = "lower_instalments"
    /** Bring debt under the next share of assets. */
    case lowerDebtToAsset = "lower_debt_to_asset"
}

/** One step, with the numbers its sentence needs; a field a kind does not use is nil. */
package struct ScoreStepDTO: Hashable, Sendable {
    /** What the step asks for. */
    package let kind: StepKindDTO
    /** Score points it is estimated to add ("+4 Poin"). */
    package let estimatedGain: Int
    /** The debt's name, for paying off or relief ("Paylater A"). */
    package let debtName: String?
    /** What is left on that debt. */
    package let remaining: Int?
    /** The amount now: the fund, savings, instalments or total debt. */
    package let currentAmount: Int?
    /** The amount to reach. */
    package let targetAmount: Int?
    /** The fund's target multiple of essential spending (1, 3, 7.5…). */
    package let targetMultiple: Double?
    /** The target share of income or assets, in percent. */
    package let targetPercent: Int?

    init(_ step: Components.Schemas.Step) throws {
        kind = try bridged(step.kind)
        estimatedGain = step.estimatedGain
        debtName = step.debtName
        remaining = step.remaining
        currentAmount = step.currentAmount
        targetAmount = step.targetAmount
        targetMultiple = step.targetMultiple
        targetPercent = step.targetPercent
    }
}
