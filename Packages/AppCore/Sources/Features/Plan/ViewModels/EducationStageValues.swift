import Domain

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
    /** Jakarta, Pulau Jawa, Luar Pulau Jawa, Luar Negeri. */
    case jakarta, java, outsideJava, abroad
}

/** "Jenis Sekolah". */
package enum EducationSchool: CaseIterable, Equatable, Sendable {
    /** Negeri, Swasta, Nasional Plus, Internasional. */
    case `public`, `private`, nationalPlus, international
}

/** Hasil Simulasi · Pendidikan Anak: the child, the plan, and each chosen stage's school. */
package struct EducationGoalOutcome: Equatable, Sendable {
    /** "Nama Anak". */
    package let childName: String
    /** The engine's plan of the chosen stages. */
    package let plan: EducationPlan
    /** The chosen stages' values, in the plan's order. */
    package let details: [EducationStageValues]
}

extension EducationStage {
    /** Its place from SD / MI (0) to S1 / D4 (3). */
    package var order: Int {
        switch self {
        case .primary: 0
        case .juniorHigh: 1
        case .seniorHigh: 2
        case .bachelor: 3
        }
    }
}
