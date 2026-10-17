import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("HouseDownPaymentFormModel")
struct HouseDownPaymentFormModelTests {
    @Test("the board's persona: DP Rp90.000.000,00 of Rp450.000.000,00, 80% loan, Cocok, and its KPR")
    func persona() throws {
        let form = HouseDownPaymentFormModel.sample()
        #expect(form.downPaymentNow == 90_000_000 && form.loanNow?.amount == 360_000_000 && form.loanNow?.percent == 80)
        let result = try #require(form.result)
        #expect(form.canCalculate)
        #expect(result.goal.target == 114_865_341 && result.goal.projection.result == 118_666_823)
        #expect(result.goal.projection.fit == .fits)
        #expect(result.mortgage.fixInstalment == 2_684_063 && result.mortgage.floatInstalment == 3_591_610)
        #expect(result.mortgage.health == .healthy && result.mortgage.costs.total == 40_850_000)
    }

    @Test("Hitung waits for every amount and rate, and a DP between 0% and 100%")
    func incomplete() {
        let form = HouseDownPaymentFormModel()
        #expect(form.result == nil && !form.canCalculate && form.downPaymentNow == nil && form.loanNow == nil)
        let full = HouseDownPaymentFormModel.sample()
        full.downPaymentRate = "100"
        #expect(full.result == nil)
        full.downPaymentRate = "20"
        full.fixRate = ""
        #expect(full.result == nil)
    }

    @Test("nothing saved yet and no NJOP-TKP count as Rp0,00")
    func emptyOptionals() throws {
        let form = HouseDownPaymentFormModel.sample()
        form.present = ""
        form.njopTkp = ""
        let result = try #require(form.result)
        #expect(result.goal.present == 0 && result.mortgage.njopTkp == 0)
        #expect(result.mortgage.costs.bphtb == 22_500_000)
    }

    @Test("Jadikan Pos Budget stores what the device computed, due in the goal's years")
    func draft() throws {
        let result = try #require(HouseDownPaymentFormModel.sample().result)
        let draft = result.draft(today: CalendarDay(year: 2026, month: 10, day: 17))
        #expect(draft.kind == .houseDownPayment && draft.inBudget && draft.targetAmount == 114_865_341)
        #expect(draft.targetDate == CalendarDay(year: 2031, month: 10, day: 17) && draft.initialAmount == 10_000_000)
        #expect(draft.monthlyDeposit == 1_500_000 && draft.inputs["tenorYears"] == .number(20))
    }

    @Test("a percent reads with a comma or a dot of thousands, and a count only above zero")
    func inputs() {
        #expect(RateInput.rate("6,50") == 0.065 && RateInput.rate("5") == 0.05 && RateInput.rate("") == nil)
        #expect(RateInput.rate("-1") == nil && RateInput.count("5") == 5 && RateInput.count("0") == nil)
    }
}

@MainActor
@Suite("GoalBudgetModel")
struct GoalBudgetModelTests {
    private let service = FakeGoalService()
    private let draft = GoalDraft(
        kind: .wedding, name: "Menikah", inputs: [:], initialAmount: 15_000_000, monthlyDeposit: 6_500_000,
        targetAmount: 192_937_500, targetDate: CalendarDay(year: 2028, month: 10, day: 17), inBudget: true)

    @Test("creates the goal once and keeps it")
    func saves() async {
        let model = GoalBudgetModel(service: service)
        async let first: Void = model.save(draft)
        async let second: Void = model.save(draft)
        _ = await (first, second)
        #expect(await service.created == [draft] && model.saved?.id == "goal-1" && !model.isSaving)
    }

    @Test(
        "a refused, invalid or lost create shows its problem, and Coba Lagi sends it again",
        arguments: [FakeGoalService.problem as any Error, URLError(.notConnectedToInternet)])
    func fails(error: any Error) async {
        await service.configure { $0.failing[.create] = error }
        let model = GoalBudgetModel(service: service)
        await model.save(draft)
        #expect(model.failure == AppProblem(error) && model.saved == nil)
        await service.configure { $0.failing = [:] }
        await model.save(draft)
        #expect(model.failure == nil && model.saved != nil)
    }
}
