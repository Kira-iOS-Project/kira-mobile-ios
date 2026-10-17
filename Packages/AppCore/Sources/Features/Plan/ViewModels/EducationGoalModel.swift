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
    package private(set) var stageValues: [EducationStage: EducationStageValues]
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
        stageValues = Dictionary(uniqueKeysWithValues: EducationStage.allCases.map { ($0, .average(for: $0)) })
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
        stageValues[stage] ?? .average(for: stage)
    }

    /** Simpan Jenjang. */
    package func save(_ values: EducationStageValues, for stage: EducationStage) {
        stageValues[stage] = values
    }

    /** Whether everything Hitung needs is filled in. */
    package var canCalculate: Bool { outcome != nil }

    /** Hitung: the plan and what goes with it; nil while something is missing or out of range. */
    package var outcome: EducationGoalOutcome? {
        let name = childName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, let age = Int(childAge.filter(\.isNumber)), age >= 0, age < EducationStage.bachelor.entryAge,
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

/** Atur Jenjang: where and what kind of school, and its costs at today's prices. */
package struct EducationStageValues: Equatable, Sendable {
    /** "Daerah Sekolah". */
    package var region: EducationRegion
    /** "Jenis Sekolah". */
    package var school: EducationSchool
    /** "Perkiraan Uang Pangkal". */
    package var entryFee: String
    /** "Perkiraan Uang Sekolah". */
    package var fee: String
    /** "Uang Sekolah Dibayar per". */
    package var feePeriod: FeePeriod
    /** "Perkiraan Biaya Lain-lain", in percent of the total. */
    package var otherRate: String

    /** A stage's values as typed. */
    package init(
        region: EducationRegion, school: EducationSchool, entryFee: String, fee: String, feePeriod: FeePeriod,
        otherRate: String
    ) {
        self.region = region
        self.school = school
        self.entryFee = entryFee
        self.fee = fee
        self.feePeriod = feePeriod
        self.otherRate = otherRate
    }

    /** The board's averages (TujuanPendidikan's Biaya per jenjang), Jakarta. */
    package static func average(for stage: EducationStage) -> EducationStageValues {
        switch stage {
        case .primary:
            EducationStageValues(
                region: .jakarta, school: .private, entryFee: "23.000.000", fee: "2.000.000", feePeriod: .month,
                otherRate: "10")
        case .juniorHigh:
            EducationStageValues(
                region: .jakarta, school: .private, entryFee: "30.000.000", fee: "2.400.000", feePeriod: .month,
                otherRate: "10")
        case .seniorHigh:
            EducationStageValues(
                region: .jakarta, school: .private, entryFee: "22.000.000", fee: "1.800.000", feePeriod: .month,
                otherRate: "10")
        case .bachelor:
            EducationStageValues(
                region: .jakarta, school: .public, entryFee: "12.000.000", fee: "7.000.000", feePeriod: .semester,
                otherRate: "10")
        }
    }

    /** Whether Simpan Jenjang may keep it. */
    package var isValid: Bool { level(.primary) != nil }

    /** The engine's stage; nil while a figure is missing or out of range. */
    package func level(_ stage: EducationStage) -> EducationLevel? {
        guard let entry = EducationInput.rupiah(entryFee), let fee = EducationInput.rupiah(fee),
            let other = EducationInput.percent(otherRate)
        else { return nil }
        return EducationLevel(stage: stage, entryFee: entry, fee: fee, feePeriod: feePeriod, otherRate: other)
    }
}

/** "Daerah Sekolah". */
package enum EducationRegion: CaseIterable, Equatable, Sendable {
    case jakarta, java, outsideJava, abroad
}

/** "Jenis Sekolah". */
package enum EducationSchool: CaseIterable, Equatable, Sendable {
    case `public`, `private`, nationalPlus, international
}

/** Hasil Simulasi · Pendidikan Anak: the child, the plan, and each chosen stage's school. */
package struct EducationGoalOutcome: Equatable, Sendable {
    package let childName: String
    package let plan: EducationPlan
    /** The chosen stages' values, in the plan's order. */
    package let details: [EducationStageValues]
}

extension EducationStage {
    /** Its place from SD / MI (0) to S1 / D4 (3). */
    package var order: Int { Self.allCases.firstIndex(of: self) ?? 0 }
}

/** Reads the form's text: whole rupiah (grouped while typing) and a percent with a comma or a dot. */
private enum EducationInput {
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
