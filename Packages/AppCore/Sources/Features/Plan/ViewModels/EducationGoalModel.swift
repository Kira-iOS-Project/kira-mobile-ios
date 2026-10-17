import Domain
import Foundation
import Observation

/**
 Tujuan Baru · Pendidikan Anak (REN-02c, board TujuanPendidikan) with Atur Jenjang (REN-02i, board
 TujuanPendidikanJenjang): the child, the first and last stage, each stage's costs at today's prices
 (the board's averages to start with), the parents' income, what is collected already, education
 inflation (15%), and the strategy. Hitung hands `EducationPlan` (compounding yearly, as the board
 does) to Hasil Simulasi (REN-04d).
 */
@MainActor @Observable
package final class EducationGoalModel {
    /** "Nama Anak". */
    package var childName: String
    /** "Usia Saat Ini", in years. */
    package var childAge: String
    /** "Jenjang Awal". */
    package var firstStage: EducationStage {
        didSet { if lastStage.order < firstStage.order { lastStage = firstStage } }
    }
    /** "Jenjang Akhir". */
    package var lastStage: EducationStage {
        didSet { if lastStage.order < firstStage.order { firstStage = lastStage } }
    }
    /** Every stage's costs, chosen or not, so a stage keeps its numbers when it comes back. */
    private var stageValues: [EducationStageValues]
    /** "Penghasilan Orang Tua Saat Ini". */
    package var income: String
    /** "Dana Pendidikan yang Sudah Terkumpul". */
    package var present: String
    /** "Inflasi Biaya Pendidikan", in percent. */
    package var inflation: String
    /** "Target Investasi per Bulan". */
    package var deposit: String
    /** "Sudah Tahu Mau Investasi di Mana?": Belum counts the return as 0%. */
    package var knowsWhere: Bool
    /** "Target Return Investasi", in percent. */
    package var annualReturn: String

    /** A form with the board's averages per stage, SD / MI to S1 / D4, and 15% inflation. */
    package init() {
        childName = ""
        childAge = ""
        firstStage = .primary
        lastStage = .bachelor
        stageValues = EducationStage.allCases.map { .average(for: $0) }
        income = ""
        present = ""
        inflation = "15"
        deposit = ""
        knowsWhere = true
        annualReturn = ""
    }

    /** The stages from Jenjang Awal to Jenjang Akhir, youngest first. */
    package var stages: [EducationStage] {
        EducationStage.allCases.filter { $0.order >= firstStage.order && $0.order <= lastStage.order }
    }

    /** One stage's costs, as Atur Jenjang shows them. */
    package func values(for stage: EducationStage) -> EducationStageValues {
        stageValues[stage.order]
    }

    /** Simpan Jenjang. */
    package func save(_ values: EducationStageValues, for stage: EducationStage) {
        stageValues[stage.order] = values
    }

    /**
     Ubah Angka with a recommendation chosen under Supaya Tercapai: Naikkan Investasi types its
     deposit, Pilih Return Lebih Tinggi its return (investing, then); none leaves the form as it is.
     */
    package func apply(_ recommendation: GoalRecommendation?) {
        switch recommendation {
        case .raiseDeposit(let amount): deposit = AmountInput.text(for: amount)
        case .raiseReturn(let rate):
            knowsWhere = true
            annualReturn = String(Int((rate * 100).rounded()))
        case .extendYears, .extendMonths, nil: break
        }
    }

    /** Whether everything Hitung needs is filled in. */
    package var canCalculate: Bool { outcome != nil }

    /** Hitung: the plan and what goes with it; nil while something is missing or out of range. */
    package var outcome: EducationGoalOutcome? {
        let name = childName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, let age = Int(childAge.filter(\.isNumber)), age >= 0,
            age < EducationStage.bachelor.entryAge,
            let income = EducationInput.rupiah(income), income > 0, let inflation = EducationInput.percent(inflation),
            let deposit = EducationInput.rupiah(deposit)
        else { return nil }
        let rate: Double?
        if knowsWhere {
            guard let typed = EducationInput.percent(annualReturn) else { return nil }
            rate = typed
        } else {
            rate = nil
        }
        var levels: [EducationLevel] = []
        for stage in stages {
            guard let level = values(for: stage).level(stage) else { return nil }
            levels.append(level)
        }
        let plan = EducationPlan(
            childAge: age, levels: levels, inflation: inflation, income: income,
            present: EducationInput.rupiah(present) ?? 0, deposit: deposit, annualReturn: rate)
        return EducationGoalOutcome(
            childName: name, plan: plan, details: stages.map { values(for: $0) })
    }
}

/** Reads the form's text: whole rupiah (grouped while typing) and a percent with a comma or a dot. */
enum EducationInput {
    /** Whole rupiah; nil when nothing is typed. */
    static func rupiah(_ text: String) -> Int? {
        AmountInput.value(of: text)
    }

    /** A percent as a fraction, from 0 to 100%; nil otherwise. */
    static func percent(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value >= 0, value <= 100 else { return nil }
        return value / 100
    }
}
