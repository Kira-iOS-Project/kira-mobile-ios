import Domain
import Testing

@testable import Features

/** Jadikan Pos Budget's drafts for Kendaraan, Barang Impian, Lainnya and Dana Pensiun. */
@MainActor
@Suite("GoalOutcomeDrafts")
struct GoalOutcomeDraftsTests {
    private let today = CalendarDay(year: 2026, month: 10, day: 17)

    @Test("Kendaraan: its target, deposit and what is saved, due after its months, in the budget")
    func vehicle() throws {
        var values = PriceGoalValues()
        values.duration = "2"
        values.price = "30.000.000"
        values.downPayment = "25"
        values.present = "2.000.000"
        values.deposit = "300.000"
        values.annualReturn = "5"
        let outcome = try #require(PriceGoalModel(kind: .vehicle, horizon: .years, values: values).outcome)
        let draft = outcome.draft(kind: .vehicle, today: today)
        #expect(draft.kind == .vehicle && draft.name == "Kendaraan" && draft.inBudget)
        #expect(draft.targetAmount == 8_268_750 && draft.monthlyDeposit == 300_000 && draft.initialAmount == 2_000_000)
        #expect(draft.targetDate == CalendarDay(year: 2028, month: 10, day: 17))
        #expect(draft.inputs["price"] == .number(30_000_000))
    }

    @Test("Barang Impian keeps the person's name and counts its months")
    func goods() throws {
        var values = PriceGoalValues()
        values.name = "Laptop Baru"
        values.duration = "10"
        values.price = "15.000.000"
        values.downPayment = "100"
        values.deposit = "1.500.000"
        values.annualReturn = "4"
        let outcome = try #require(PriceGoalModel(kind: .goods, horizon: .months, values: values).outcome)
        let draft = outcome.draft(kind: .goods, today: today)
        #expect(draft.kind == .goods && draft.name == "Laptop Baru")
        #expect(draft.targetDate == CalendarDay(year: 2027, month: 8, day: 17))
    }

    @Test("Lainnya: the name, the amount as the target, due after its years")
    func other() throws {
        var values = OtherGoalValues()
        values.name = "Liburan Keluarga"
        values.amount = "25.000.000"
        values.duration = "2"
        values.present = "0"
        values.deposit = "1.000.000"
        values.annualReturn = "5"
        let draft = try #require(OtherGoalModel(values: values).outcome).draft(today: today)
        #expect(draft.kind == .other && draft.name == "Liburan Keluarga")
        #expect(draft.targetAmount == 25_000_000 && draft.monthlyDeposit == 1_000_000)
        #expect(draft.targetDate == CalendarDay(year: 2028, month: 10, day: 17))
        #expect(draft.inputs["period"] == .text("month"))
    }

    @Test("Dana Pensiun: due at retirement, 27 years on")
    func retirement() throws {
        let model = RetirementGoalModel()
        model.expense = "6.000.000"
        model.age = "28"
        model.retirementAge = "55"
        model.present = "25.000.000"
        model.deposit = "2.000.000"
        model.annualReturn = "10"
        let outcome = try #require(model.outcome)
        let draft = outcome.draft(today: today)
        #expect(draft.kind == .retirement && draft.name == "Dana Pensiun")
        #expect(draft.targetAmount == outcome.projection.target && draft.monthlyDeposit == 2_000_000)
        #expect(draft.targetDate == CalendarDay(year: 2053, month: 10, day: 17))
    }

    @Test("Pendidikan: Raka's target, due when S1 / D4 ends, each stage's figures keyed flat")
    func education() throws {
        let model = EducationGoalModel()
        model.childName = "Raka"
        model.childAge = "3"
        model.income = "15.000.000"
        model.present = "20.000.000"
        model.deposit = "2.000.000"
        model.annualReturn = "8"
        let draft = try #require(model.outcome).draft(today: today)
        #expect(draft.kind == .education && draft.name == "Pendidikan Raka" && draft.inBudget)
        #expect(draft.targetAmount == 1_849_307_708 && draft.monthlyDeposit == 2_000_000)
        #expect(draft.initialAmount == 20_000_000)
        #expect(draft.targetDate == CalendarDay(year: 2045, month: 10, day: 17))
        #expect(draft.inputs["level.bachelor.feePeriod"] == .text("semester"))
        #expect(draft.inputs["level.primary.entryFee"] == .number(23_000_000))
        #expect(draft.inputs["level.bachelor.school"] == .text("public"))
        model.knowsWhere = false
        #expect(try #require(model.outcome).draft(today: today).inputs["annualReturn"] == .empty)
    }
}

