import Domain
import Testing

@testable import Features

/**
 Ubah Tujuan opens each calculator on the figures its goal was saved with: Hitung on the reopened
 form gives back the draft that was saved, inputs, amounts and date alike.
 */
@MainActor
@Suite("GoalEditing")
struct GoalEditingTests {
    private let today = CalendarDay(year: 2026, month: 10, day: 17)

    /** The goal the API would hand back for `draft`. */
    private func saved(_ draft: GoalDraft) -> GoalDetail {
        GoalDetail(
            summary: GoalSummary(
                id: "goal-1", kind: draft.kind, name: draft.name, targetAmount: draft.targetAmount,
                targetDate: draft.targetDate, monthlyDeposit: draft.monthlyDeposit, savedAmount: draft.initialAmount),
            inputs: draft.inputs, initialAmount: draft.initialAmount, inBudget: draft.inBudget)
    }

    @Test("Kendaraan and Barang Impian reopen with their price, DP, inflation, horizon and strategy")
    func price() throws {
        var vehicle = PriceGoalValues()
        vehicle.duration = "2"
        vehicle.price = "30.000.000"
        vehicle.downPayment = "25"
        vehicle.inflation = "4,5"
        vehicle.present = "2.000.000"
        vehicle.deposit = "300.000"
        vehicle.annualReturn = "5"
        let draft = try #require(PriceGoalModel(kind: .vehicle, horizon: .years, values: vehicle).outcome)
            .draft(kind: .vehicle, today: today)
        let reopened = PriceGoalValues(editing: saved(draft), horizon: .years)
        #expect(reopened == vehicle)
        var goods = vehicle
        goods.name = "Laptop Baru"
        goods.duration = "10"
        let goodsDraft = try #require(PriceGoalModel(kind: .goods, horizon: .months, values: goods).outcome)
            .draft(kind: .goods, today: today)
        #expect(PriceGoalValues(editing: saved(goodsDraft), horizon: .months) == goods)
    }

    @Test("Lainnya reopens its amount, a yearly deposit as typed, and its timing")
    func other() throws {
        var values = OtherGoalValues()
        values.name = "Liburan"
        values.amount = "24.000.000"
        values.duration = "2"
        values.present = "1.000.000"
        values.period = .year
        values.timing = .end
        values.deposit = "6.000.000"
        values.annualReturn = "4"
        let draft = try #require(OtherGoalModel(values: values).outcome).draft(today: today)
        #expect(OtherGoalValues(editing: saved(draft)) == values)
        var monthly = values
        monthly.period = .month
        monthly.timing = .start
        monthly.deposit = "500.000"
        let monthlyDraft = try #require(OtherGoalModel(values: monthly).outcome).draft(today: today)
        #expect(OtherGoalValues(editing: saved(monthlyDraft)) == monthly)
    }

    @Test("Dana Pensiun reopens its retirement age from today's age and the years left")
    func retirement() throws {
        var values = RetirementGoalValues()
        values.expense = "8.000.000"
        values.age = "30"
        values.retirementAge = "55"
        values.present = "10.000.000"
        values.deposit = "2.000.000"
        values.annualReturn = "7"
        let draft = try #require(RetirementGoalModel(values: values).outcome).draft(today: today)
        #expect(RetirementGoalValues(editing: saved(draft)) == values)
    }

    @Test("Dana Darurat, DP Rumah and Menikah give back the draft they were saved with")
    func sameDraft() throws {
        let fund = EmergencyFundGoalModel(prefill: PlanPrefill(essentialExpense: 4_200_000, maritalStatus: .married))
        fund.dependants = "2"
        fund.months = "30"
        fund.present = "4.800.000"
        fund.deposit = "650.000"
        fund.annualReturn = "4"
        let fundDraft = try #require(fund.outcome).draft(today: today)
        #expect(try #require(EmergencyFundGoalModel.editing(saved(fundDraft)).outcome).draft(today: today) == fundDraft)

        let houseDraft = try #require(HouseDownPaymentFormModel.sample().result).draft(today: today)
        let house = HouseDownPaymentFormModel.editing(saved(houseDraft))
        #expect(try #require(house.result).draft(today: today) == houseDraft)

        let wedding = WeddingFormModel.sample()
        let weddingDraft = try #require(wedding.result).draft(today: today, preset: wedding.preset)
        let reopened = WeddingFormModel.editing(saved(weddingDraft))
        #expect(reopened.budgeting == .simple)
        #expect(try #require(reopened.result).draft(today: today, preset: reopened.preset) == weddingDraft)
    }

    @Test("Pendidikan Anak reopens each saved stage, and Belum (no return) stays Belum")
    func education() throws {
        let model = EducationGoalModel()
        model.childName = "Raka"
        model.childAge = "3"
        model.firstStage = .juniorHigh
        model.income = "15.000.000"
        model.present = "20.000.000"
        model.deposit = "2.000.000"
        model.annualReturn = "8"
        var bachelor = model.values(for: .bachelor)
        bachelor.region = .abroad
        bachelor.school = .private
        bachelor.feePeriod = .year
        model.save(bachelor, for: .bachelor)
        let draft = try #require(model.outcome).draft(today: today)
        let reopened = EducationGoalModel.editing(saved(draft))
        #expect(reopened.stages == [.juniorHigh, .seniorHigh, .bachelor])
        #expect(reopened.values(for: .bachelor) == bachelor)
        #expect(try #require(reopened.outcome).draft(today: today) == draft)

        model.knowsWhere = false
        let unsure = try #require(model.outcome).draft(today: today)
        #expect(!EducationGoalModel.editing(saved(unsure)).knowsWhere)
    }
}

/** A goal saved without some input: its field opens empty, or on the form's own default. */
@MainActor
@Suite("GoalEditing missing inputs")
struct GoalEditingMissingInputTests {
    private let today = CalendarDay(year: 2026, month: 10, day: 17)

    @Test("a goal missing an input leaves that field empty, so Hitung waits for it")
    func missing() {
        let goal = GoalDetail(
            summary: GoalSummary(
                id: "g", kind: .other, name: "Liburan", targetAmount: 1, targetDate: today, monthlyDeposit: 0,
                savedAmount: 0),
            inputs: ["years": .text("dua")])
        let other = OtherGoalValues(editing: goal)
        #expect(other.duration.isEmpty && other.annualReturn.isEmpty)
        let retirement = RetirementGoalValues(editing: goal)
        #expect(retirement.age.isEmpty && retirement.retirementAge.isEmpty)
        #expect(EducationGoalModel.editing(goal).childName.isEmpty)
        #expect(GoalEditing.percent(0.12345) == "12,35")
        #expect(EmergencyFundGoalModel.editing(goal).dependants == "0")
        let house = HouseDownPaymentFormModel.editing(goal)
        #expect(house.tenorYears == 20 && house.fixYears == 3 && house.price.isEmpty)
        var stageOnly = goal
        stageOnly.inputs = ["level.primary.fee": .number(500_000)]
        let education = EducationGoalModel.editing(stageOnly)
        let average = EducationStageValues.average(for: .primary)
        #expect(education.stages == [.primary])
        #expect(education.values(for: .primary).region == average.region)
        #expect(education.values(for: .primary).school == average.school)
        #expect(education.values(for: .primary).feePeriod == average.feePeriod)
    }
}
