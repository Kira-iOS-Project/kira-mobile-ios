import Domain
import Testing

@testable import Features

@MainActor
@Suite("PriceGoalModel")
struct PriceGoalModelTests {
    private func vehicle() -> PriceGoalModel {
        var values = PriceGoalValues()
        values.duration = "2"
        values.price = "30.000.000"
        values.downPayment = "25"
        values.present = "2.000.000"
        values.deposit = "300.000"
        values.annualReturn = "5"
        return PriceGoalModel(kind: .vehicle, horizon: .years, values: values)
    }

    @Test("Kendaraan as on its boards: DP and KKB, the inflated DP target, and the result")
    func vehicleBoard() throws {
        let model = vehicle()
        #expect(model.downPaymentAmount == 7_500_000 && model.loanPrincipal == 22_500_000)
        let outcome = try #require(model.outcome)
        #expect(outcome.projection.target == 8_268_750 && outcome.projection.result == 9_797_141)
        #expect(outcome.projection.principal == 9_200_000 && outcome.projection.growth == 597_141)
        #expect(outcome.projection.fit == .fits && outcome.months == 24)
        #expect(outcome.assetClasses == [.fixedIncomeFund, .governmentBond])
    }

    @Test("Barang Impian as on its boards: named, in months, bought in cash")
    func goodsBoard() throws {
        var values = PriceGoalValues()
        values.name = "  Laptop Baru "
        values.duration = "12"
        values.price = "15.000.000"
        values.downPayment = "100"
        values.present = "2.000.000"
        values.deposit = "1.150.000"
        values.annualReturn = "5"
        let model = PriceGoalModel(kind: .goods, horizon: .months, values: values)
        #expect(model.loanPrincipal == nil)
        let outcome = try #require(model.outcome)
        #expect(outcome.name == "Laptop Baru" && outcome.months == 12)
        #expect(outcome.projection.target == 15_750_000 && outcome.projection.result == 16_281_844)
    }

    @Test("Hitung waits for every field: a missing name, duration, price, DP or return holds it")
    func incomplete() {
        let model = vehicle()
        #expect(model.canCalculate)
        model.downPayment = "0"
        #expect(!model.canCalculate)
        model.downPayment = "25"
        model.duration = ""
        #expect(!model.canCalculate && model.outcome == nil)
        let goods = PriceGoalModel(kind: .goods, horizon: .months)
        #expect(goods.inflation == "5" && !goods.canCalculate && goods.downPaymentAmount == nil)
        model.duration = "2"
        model.present = ""
        #expect(model.outcome?.present == 0)
    }
}

@Suite("GoalInput and GoalShares")
struct GoalInputTests {
    @Test("rupiah, counts and percents with a comma or a dot")
    func parse() {
        #expect(GoalInput.rupiah("1.150.000") == 1_150_000 && GoalInput.rupiah("") == nil)
        #expect(GoalInput.count("27") == 27 && GoalInput.count("0") == nil && GoalInput.count("") == nil)
        #expect(GoalInput.percent("4,5") == 0.045 && GoalInput.percent(" 10 ") == 0.1)
        #expect(GoalInput.percent("101") == nil && GoalInput.percent("x") == nil)
    }

    @Test("pokok and imbal hasil as the boards round them, always adding up to 100")
    func shares() {
        let retirement = GoalShares(principal: 673_000_000, growth: 3_013_687_857)
        #expect(retirement.principalPercent == 18 && retirement.growthPercent == 82)
        #expect(GoalShares(principal: 9_200_000, growth: 597_141).principalPercent == 94)
        let empty = GoalShares(principal: 0, growth: 0)
        #expect(empty.principalShare == 1 && empty.growthPercent == 0)
    }
}
