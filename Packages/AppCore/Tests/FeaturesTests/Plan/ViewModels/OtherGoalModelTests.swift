import Domain
import Testing

@testable import Features

@MainActor
@Suite("OtherGoalModel")
struct OtherGoalModelTests {
    private func board() -> OtherGoalModel {
        var values = OtherGoalValues()
        values.name = "Liburan Keluarga"
        values.amount = "25.000.000"
        values.duration = "2"
        values.present = "0"
        values.deposit = "1.000.000"
        values.annualReturn = "5"
        return OtherGoalModel(values: values)
    }

    @Test("Lainnya as on its boards: the amount as the target, monthly at the start of each month")
    func boardFigures() throws {
        let outcome = try #require(board().outcome)
        #expect(outcome.projection.target == 25_000_000 && outcome.projection.result == 25_290_862)
        #expect(outcome.projection.principal == 24_000_000 && outcome.projection.fit == .fits)
        #expect(outcome.period == .month && outcome.timing == .start && outcome.years == 2)
    }

    @Test("yearly deposits at the end of each year reach less than monthly ones at the start")
    func yearlyAtTheEnd() throws {
        let model = board()
        model.period = .year
        model.timing = .end
        model.deposit = "12.000.000"
        let outcome = try #require(model.outcome)
        #expect(outcome.projection.principal == 24_000_000)
        #expect(outcome.projection.result < 25_290_862 && outcome.timing == .end)
    }

    @Test("Hitung waits for a name, an amount, the years, a deposit and a return")
    func incomplete() {
        let model = board()
        model.name = " "
        #expect(!model.canCalculate)
        let empty = OtherGoalModel()
        #expect(!empty.canCalculate && empty.period == .month && empty.timing == .start)
    }
}
