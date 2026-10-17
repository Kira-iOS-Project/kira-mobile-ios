import Domain
import Testing

@testable import Features

/** Kalkulator Dana Darurat's form (REN-03) on the KalkulatorDarurat board's persona. */
@MainActor
@Suite("EmergencyFundGoalModel")
struct EmergencyFundGoalModelTests {
    private func persona() -> EmergencyFundGoalModel {
        let form = EmergencyFundGoalModel(
            prefill: PlanPrefill(essentialExpense: 4_200_000, emergencyFund: 4_800_000, maritalStatus: .single))
        form.months = "30"
        form.deposit = "650.000"
        form.annualReturn = "4"
        return form
    }

    @Test("prefilled from Rencana; 6× Rp4.200.000 = Rp25.200.000; Hitung is Cocok, 50:50")
    func personaOutcome() throws {
        let form = persona()
        #expect(form.essential == "4200000" && form.present == "4800000" && !form.married && form.dependants == "0")
        #expect(form.neededFund?.target == 25_200_000 && form.canCalculate)
        let outcome = try #require(form.outcome)
        #expect(outcome.multiplier == 6 && outcome.target == 25_200_000 && outcome.half == 12_600_000)
        #expect(outcome.projection.result == 25_844_674 && outcome.projection.fit == .fits)
        #expect(outcome.recommendations.isEmpty && outcome.assetClasses.contains(.usDollar))
        #expect(outcome.essential == 4_200_000 && outcome.months == 30 && outcome.present == 4_800_000)
        #expect(
            outcome.deposit == 650_000 && outcome.annualReturn == 0.04 && !outcome.married && outcome.dependants == 0)
    }

    @Test("married with two dependants needs 15×; a short plan recommends; the draft keeps the inputs")
    func marriedShort() throws {
        let form = persona()
        form.married = true
        form.dependants = "2"
        let outcome = try #require(form.outcome)
        #expect(outcome.multiplier == 15 && outcome.projection.fit == .short && outcome.recommendations.count == 2)
        let draft = outcome.draft(today: CalendarDay(year: 2026, month: 10, day: 17))
        #expect(draft.kind == .emergencyFund && draft.targetAmount == 63_000_000 && draft.monthlyDeposit == 650_000)
        #expect(draft.inputs["essentialExpense"] == .number(4_200_000) && draft.inputs["married"] == .flag(true))
        #expect(draft.targetDate == CalendarDay(year: 2029, month: 4, day: 17) && draft.initialAmount == 4_800_000)
    }

    @Test("a prefill arriving later fills what is empty and keeps what was typed")
    func lateprefill() {
        let form = EmergencyFundGoalModel()
        form.present = "1000000"
        form.apply(
            PlanPrefill(essentialExpense: 4_200_000, emergencyFund: 9, maritalStatus: .married, dependants: 2))
        #expect(form.essential == "4200000" && form.present == "1000000" && form.married && form.dependants == "2")
        form.apply(PlanPrefill(essentialExpense: 1, maritalStatus: .single, dependants: 5))
        #expect(form.essential == "4200000" && form.married && form.dependants == "2")
    }

    @Test("nothing to work out without spending, months, a deposit or a return")
    func incomplete() {
        let empty = EmergencyFundGoalModel()
        #expect(empty.essential.isEmpty && empty.neededFund == nil && !empty.canCalculate)
        let form = persona()
        form.months = "0"
        #expect(form.outcome == nil)
        form.months = "30"
        form.annualReturn = ""
        #expect(form.outcome == nil)
    }
}
