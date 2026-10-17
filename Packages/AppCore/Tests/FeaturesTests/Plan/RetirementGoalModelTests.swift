import Domain
import Features
import Testing

/** Dana Pensiun against the board's persona (REN-CALC-FIXTURES, HasilTujuanPensiun). */
@MainActor
@Suite("RetirementGoalModel")
struct RetirementGoalModelTests {
    /** Rp6.000.000 a month, 28 → 55, 4%, Rp25.000.000 there, Rp2.000.000 a month at 10%. */
    private func persona() -> RetirementGoalModel {
        let model = RetirementGoalModel()
        model.expense = "6.000.000"
        model.age = "28"
        model.retirementAge = "55"
        model.present = "25.000.000"
        model.deposit = "2.000.000"
        model.annualReturn = "10"
        return model
    }

    @Test("opens with 4% inflation and nothing to calculate")
    func defaults() {
        let model = RetirementGoalModel()
        #expect(model.inflation == "4")
        #expect(!model.canCalculate)
        #expect(model.years == nil)
    }

    @Test("shows a year of expenses and the years to retirement while typing")
    func automatic() {
        let model = persona()
        #expect(model.annualExpense == 72_000_000)
        #expect(model.years == 27)
    }

    @Test("matches the board: target, result, pokok, status and asset classes")
    func board() throws {
        let outcome = try #require(persona().outcome)
        #expect(outcome.age == 28)
        #expect(outcome.years == 27)
        #expect(outcome.annualExpense == 207_602_537)
        #expect(outcome.projection.target == 5_190_063_437)
        #expect(outcome.projection.result == 3_686_687_857)
        #expect(outcome.projection.principal == 673_000_000)
        #expect(outcome.projection.growth == 3_013_687_857)
        #expect(outcome.projection.shortfall == 1_503_375_580)
        #expect(outcome.projection.fit == .short)
        #expect(outcome.assetClasses == [.stocks, .crypto, .indexFund, .etf])
        #expect(GoalShares(principal: outcome.projection.principal, growth: outcome.projection.growth)
            .principalPercent == 18)
    }

    @Test("recommends Rp2.950.000 a month or 12%, never more time")
    func recommendations() throws {
        let outcome = try #require(persona().outcome)
        #expect(outcome.recommendations == [.raiseDeposit(to: 2_950_000), .raiseReturn(to: 0.12)])
    }

    @Test("needs a retirement age after today's age")
    func ages() {
        let model = persona()
        model.retirementAge = "28"
        #expect(model.years == nil)
        #expect(!model.canCalculate)
    }

    @Test("needs the expenses, the deposit and both rates")
    func missing() {
        for clear in [\RetirementGoalModel.expense, \.deposit, \.annualReturn, \.inflation] {
            let model = persona()
            model[keyPath: clear] = ""
            #expect(!model.canCalculate)
        }
        let model = persona()
        model.expense = "0"
        #expect(!model.canCalculate)
    }

    @Test("counts nothing set aside as zero, and reads a comma rate")
    func lenient() throws {
        let model = persona()
        model.present = ""
        model.inflation = "4,0"
        let outcome = try #require(model.outcome)
        #expect(outcome.present == 0)
        #expect(outcome.projection.target == 5_190_063_437)
    }
}
