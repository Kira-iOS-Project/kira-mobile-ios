import Domain
import Observation

/**
 Kalkulator Dana Darurat (REN-03): the month's essential spending (from the last three months'
 records, else the health check), whether the person is married, their dependants, the months to
 the fund, what is there already, and the strategy. Hitung works out Hasil Simulasi (REN-04).
 */
@MainActor @Observable
package final class EmergencyFundGoalModel {
    /** Pengeluaran Pokok per Bulan, in rupiah as typed. */
    package var essential: String
    /** Sudah Menikah? */
    package var married: Bool
    /** Jumlah Tanggungan, as typed. */
    package var dependants: String
    /** Terkumpul dalam … Bulan Lagi, as typed. */
    package var months: String
    /** Dana Darurat yang Sudah Ada, in rupiah as typed. */
    package var present: String
    /** Target Investasi per bulan, in rupiah as typed. */
    package var deposit: String
    /** Return Investasi, in percent a year as typed. */
    package var annualReturn: String

    /** A form starting from what Rencana knows (`prefill`). */
    package init(prefill: PlanPrefill = PlanPrefill()) {
        essential = prefill.essentialExpense.map(String.init) ?? ""
        married = prefill.maritalStatus == .married
        dependants = String(prefill.dependants ?? 0)
        months = ""
        present = prefill.emergencyFund.map(String.init) ?? ""
        deposit = ""
        annualReturn = ""
    }

    /** Rencana's prefill arriving after the form opened: it fills only what is still empty or untouched. */
    package func apply(_ prefill: PlanPrefill) {
        if essential.isEmpty, let value = prefill.essentialExpense { essential = String(value) }
        if present.isEmpty, let value = prefill.emergencyFund { present = String(value) }
        if !married, prefill.maritalStatus == .married { married = true }
        if dependants == "0", let value = prefill.dependants { dependants = String(value) }
    }

    /** The fund the answers so far need ("Dana Darurat yang Kamu Butuhkan"), before Hitung. */
    package var neededFund: EmergencyFund? {
        guard let essential = GoalFieldInput.rupiah(essential), essential > 0 else { return nil }
        return EmergencyFund(
            monthlyEssential: essential, married: married, dependants: GoalFieldInput.count(dependants) ?? 0,
            months: 0, present: 0, deposit: 0, annualReturn: 0)
    }

    /** Whether everything Hitung needs is filled in. */
    package var canCalculate: Bool { outcome != nil }

    /** Hitung: the projection and what goes with it; nil while something is missing. */
    package var outcome: EmergencyFundOutcome? {
        guard let needed = neededFund, let months = GoalFieldInput.count(months), months > 0,
            let deposit = GoalFieldInput.rupiah(deposit), let annualReturn = GoalFieldInput.percent(annualReturn)
        else { return nil }
        let fund = EmergencyFund(
            monthlyEssential: needed.monthlyEssential, married: married, dependants: needed.dependants,
            months: months, present: GoalFieldInput.rupiah(present) ?? 0, deposit: deposit,
            annualReturn: annualReturn)
        return EmergencyFundOutcome(fund: fund)
    }
}

/** Hasil Simulasi · Dana Darurat: the figures the form gave and what the engine made of them. */
package struct EmergencyFundOutcome: Equatable, Sendable {
    /** Pengeluaran Pokok per Bulan. */
    package let essential: Int
    /** Sudah Menikah? */
    package let married: Bool
    /** Jumlah Tanggungan. */
    package let dependants: Int
    /** The months to the fund. */
    package let months: Int
    /** Dana Darurat yang Sudah Ada. */
    package let present: Int
    /** Target Investasi per bulan. */
    package let deposit: Int
    /** The yearly return, a fraction. */
    package let annualReturn: Double
    /** Months of spending the fund covers: 6 or 9, 3 more per dependant, at most 15. */
    package let multiplier: Int
    /** Dana Darurat yang Kamu Butuhkan. */
    package let target: Int
    /** Each half of Tempat Menyimpannya. */
    package let half: Int
    /** What the engine worked out. */
    package let projection: GoalProjection
    /** Naikkan Investasi and Perpanjang Waktu (months) while it is short. */
    package let recommendations: [GoalRecommendation]
    /** Kelas Aset untuk Dana Darurat. */
    package let assetClasses: [GoalAssetClass]

    /** The outcome of `fund`. */
    package init(fund: EmergencyFund) {
        essential = fund.monthlyEssential
        married = fund.married
        dependants = fund.dependants
        months = fund.months
        present = fund.present
        deposit = fund.deposit
        annualReturn = fund.annualReturn
        multiplier = fund.multiplier
        target = fund.target
        half = fund.half
        projection = fund.projection
        recommendations = fund.recommendations
        assetClasses = EmergencyFund.assetClasses
    }

    /** What Jadikan Pos Budget stores; the API needs the essential spending (`inputs.essentialExpense`). */
    package func draft(today: CalendarDay) -> GoalDraft {
        GoalDraft(
            kind: .emergencyFund, name: "Dana Darurat",
            inputs: [
                "essentialExpense": .number(Double(essential)), "married": .flag(married),
                "dependants": .number(Double(dependants)), "months": .number(Double(months)),
                "annualReturn": .number(annualReturn),
            ],
            initialAmount: present, monthlyDeposit: deposit, targetAmount: target,
            targetDate: today.adding(months: months), inBudget: true)
    }
}
