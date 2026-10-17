/**
 The words Pendidikan Anak gives its values (TujuanPendidikan, TujuanPendidikanJenjang,
 HasilTujuanPendidikan): stages, regions, school kinds, fee periods, and the lines built from them.
 */
import Domain
import Features
import SwiftUI

extension EducationStage {
    /** "SD / MI" … "S1 / D4". */
    var title: LocalizedStringResource {
        switch self {
        case .primary: "plan.education.stage.primary"
        case .juniorHigh: "plan.education.stage.juniorHigh"
        case .seniorHigh: "plan.education.stage.seniorHigh"
        case .bachelor: "plan.education.stage.bachelor"
        }
    }

    /** "SD", "SMP", "SMA", "S1", as Atur Jenjang's notice names them. */
    var shortTitle: LocalizedStringResource {
        switch self {
        case .primary: "plan.education.stage.primary.short"
        case .juniorHigh: "plan.education.stage.juniorHigh.short"
        case .seniorHigh: "plan.education.stage.seniorHigh.short"
        case .bachelor: "plan.education.stage.bachelor.short"
        }
    }
}

extension EducationRegion {
    /** Daerah Sekolah's chip. */
    var title: LocalizedStringResource {
        switch self {
        case .jakarta: "plan.education.region.jakarta"
        case .java: "plan.education.region.java"
        case .outsideJava: "plan.education.region.outsideJava"
        case .abroad: "plan.education.region.abroad"
        }
    }
}

extension EducationSchool {
    /** Jenis Sekolah's chip. */
    var title: LocalizedStringResource {
        switch self {
        case .public: "plan.education.school.public"
        case .private: "plan.education.school.private"
        case .nationalPlus: "plan.education.school.nationalPlus"
        case .international: "plan.education.school.international"
        }
    }
}

extension FeePeriod {
    /** "Bulan", "Semester", "Tahun". */
    var title: LocalizedStringResource {
        switch self {
        case .month: "plan.education.feePeriod.month"
        case .semester: "plan.education.feePeriod.semester"
        case .year: "plan.education.feePeriod.year"
        }
    }

    /** "per bulan", "per semester", "per tahun". */
    var per: String {
        switch self {
        case .month: String(localized: "plan.education.per.month")
        case .semester: String(localized: "plan.education.per.semester")
        case .year: String(localized: "plan.education.per.year")
        }
    }
}

extension EducationStageValues {
    /** "Swasta · Jakarta · pangkal Rp23.000.000,00 · Rp2.000.000,00 per bulan". */
    var summary: LocalizedStringResource {
        let school = EducationCopy.text(school.title)
        let region = EducationCopy.text(region.title)
        let entry = (AmountInput.value(of: entryFee) ?? 0).rupiah.formatted(.rupiah)
        let fee = (AmountInput.value(of: fee) ?? 0).rupiah.formatted(.rupiah)
        return "plan.education.stage.summary \(school) \(region) \(entry) \(fee) \(feePeriod.per)"
    }
}

/** Pendidikan's lines with numbers in them, in Indonesian formatting. */
enum EducationCopy {
    private static let locale = Locale(identifier: "id_ID")

    /** A catalog entry as plain text, to place inside another entry. */
    static func text(_ resource: LocalizedStringResource) -> String { String(localized: resource) }

    /** "15", "10,5". */
    static func number(_ value: Double) -> String { value.formatted(.number.locale(locale)) }

    /** "Masuk 3 tahun lagi · 6 tahun · Swasta · Jakarta". */
    static func stageLine(_ cost: EducationCost, values: EducationStageValues) -> LocalizedStringResource {
        let school = text(values.school.title)
        let region = text(values.region.title)
        return "plan.education.result.stage \(cost.startsInYears) \(cost.years) \(school) \(region)"
    }

    /** "Sekitar 22,3% dari penghasilan orang tua saat ini, untuk SD / MI (uang sekolah ditambah 10%)." */
    static func monthlyShare(_ share: Double, level: EducationLevel) -> LocalizedStringResource {
        let percent = share.formatted(.percent.precision(.fractionLength(1)).locale(locale))
        let stage = text(level.stage.title)
        return "plan.education.result.monthly.body \(percent) \(stage) \(number(level.otherRate * 100))"
    }
}
