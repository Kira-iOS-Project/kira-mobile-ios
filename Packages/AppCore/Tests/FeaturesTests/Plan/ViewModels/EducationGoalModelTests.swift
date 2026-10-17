import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("EducationGoalModel")
struct EducationGoalModelTests {
    /** The board's persona: Raka, 3, SD / MI to S1 / D4, Rp15.000.000, Rp20.000.000, 15%, Rp2.000.000, 8%. */
    private func raka() -> EducationGoalModel {
        let model = EducationGoalModel()
        model.childName = "Raka"
        model.childAge = "3"
        model.income = "15.000.000"
        model.present = "20.000.000"
        model.deposit = "2.000.000"
        model.annualReturn = "8"
        return model
    }

    @Test("opens with the board's averages, SD / MI to S1 / D4 and 15% inflation, and cannot calculate yet")
    func defaults() {
        let model = EducationGoalModel()
        #expect(model.stages == [.primary, .juniorHigh, .seniorHigh, .bachelor])
        #expect(model.inflation == "15")
        #expect(model.knowsWhere)
        #expect(model.values(for: .bachelor).feePeriod == .semester)
        #expect(model.values(for: .bachelor).school == .public)
        #expect(model.values(for: .primary).entryFee == "23.000.000")
        #expect(!model.canCalculate)
    }

    @Test("Raka's plan matches HasilTujuanPendidikan: target, result, pokok, Belum Cocok, Rp3.300.000,00")
    func boardPersona() throws {
        let outcome = try #require(raka().outcome)
        let projection = outcome.plan.projection()
        #expect(projection.target == 1_849_307_708)
        #expect(projection.result == 1_160_601_164)
        #expect(projection.principal == 476_000_000)
        #expect(projection.shortfall == 688_706_544)
        #expect(projection.fit == .short)
        #expect(outcome.plan.yearsInvesting == 19)
        #expect(outcome.plan.recommendations() == [.raiseDeposit(to: 3_300_000)])
        #expect(outcome.plan.costs.map(\.total) == [279_384_738, 450_428_880, 510_841_880, 608_652_210])
        #expect(outcome.childName == "Raka")
    }

    @Test("Belum counts the return as 0% and ignores the return field")
    func notInvestingYet() throws {
        let model = raka()
        model.knowsWhere = false
        model.annualReturn = ""
        let outcome = try #require(model.outcome)
        #expect(outcome.plan.annualReturn == nil)
        #expect(outcome.plan.projection().result == 20_000_000 + 24_000_000 * 19)
    }

    @Test("Jenjang Awal past Jenjang Akhir moves the end along, and the other way round")
    func stageRange() {
        let model = EducationGoalModel()
        model.lastStage = .juniorHigh
        model.firstStage = .seniorHigh
        #expect(model.stages == [.seniorHigh])
        model.lastStage = .primary
        #expect(model.stages == [.primary])
    }

    @Test("Simpan Jenjang keeps a stage's values, and they feed the plan")
    func saveStage() throws {
        let model = raka()
        var values = model.values(for: .primary)
        values.fee = "12.000.000"
        values.feePeriod = .year
        values.school = .international
        model.save(values, for: .primary)
        let outcome = try #require(model.outcome)
        #expect(outcome.plan.levels.first?.fee == 12_000_000)
        #expect(outcome.plan.levels.first?.feePeriod == .year)
        #expect(outcome.details.first?.school == .international)
    }

    @Test("a missing name, an age past S1 entry, no income, a bad percent or an empty stage blocks Hitung")
    func negatives() {
        let noName = raka()
        noName.childName = "  "
        #expect(noName.outcome == nil)
        let tooOld = raka()
        tooOld.childAge = "18"
        #expect(tooOld.outcome == nil)
        let noIncome = raka()
        noIncome.income = ""
        #expect(noIncome.outcome == nil)
        let badReturn = raka()
        badReturn.annualReturn = "120"
        #expect(badReturn.outcome == nil)
        let emptyStage = raka()
        var values = emptyStage.values(for: .seniorHigh)
        values.entryFee = ""
        #expect(!values.isValid)
        emptyStage.save(values, for: .seniorHigh)
        #expect(emptyStage.outcome == nil)
    }

    @Test("Ubah Angka types the chosen deposit or return into the form; Perpanjang Waktu or none leaves it")
    func applyRecommendation() throws {
        let model = raka()
        model.apply(.raiseDeposit(to: 3_300_000))
        #expect(model.deposit == "3.300.000")
        #expect(try #require(model.outcome).plan.projection().fit == .fits)
        model.knowsWhere = false
        model.apply(.raiseReturn(to: 0.12))
        #expect(model.knowsWhere && model.annualReturn == "12")
        model.apply(.extendYears(to: 25, target: 1))
        model.apply(nil)
        #expect(model.deposit == "3.300.000" && model.annualReturn == "12")
    }

    @Test("each stage keeps its own place and values, from SD / MI to S1 / D4")
    func stageOrder() {
        let model = EducationGoalModel()
        #expect(EducationStage.allCases.map(\.order) == [0, 1, 2, 3])
        #expect(model.values(for: .juniorHigh).entryFee == "30.000.000")
        #expect(model.values(for: .seniorHigh).fee == "1.800.000")
        #expect(EducationRegion.allCases.count == 4 && EducationSchool.allCases.count == 4)
    }

    @Test("nothing collected yet counts as Rp0,00")
    func nothingCollected() throws {
        let model = raka()
        model.present = ""
        let plan = try #require(model.outcome).plan
        #expect(plan.present == 0)
        #expect(plan.projection().principal == 24_000_000 * 19)
    }
}
