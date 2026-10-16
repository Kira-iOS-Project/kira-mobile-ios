/**
 The fixed words of each indicator and group: names, tiles, the one-line description, where its
 numbers come from, and why it matters.
 */
import Domain
import SwiftUI

extension IndicatorKey {
    /** "Dana Darurat", "Rasio Menabung", … */
    var name: LocalizedStringResource {
        switch self {
        case .emergencyFund: "indicator.emergencyFund.name"
        case .savingsRatio: "indicator.savingsRatio.name"
        case .instalmentRatio: "indicator.instalmentRatio.name"
        case .consumerDebt: "indicator.consumerDebt.name"
        case .debtToAsset: "indicator.debtToAsset.name"
        case .protection: "indicator.protection.name"
        }
    }

    /** The tile beside the indicator's name. */
    var category: KiraCategory {
        switch self {
        case .emergencyFund: .emergency
        case .savingsRatio: .savings
        case .instalmentRatio, .consumerDebt: .paylater
        case .debtToAsset: .bank
        case .protection: .protection
        }
    }

    /** The line under the detail's title ("Bekalmu kalau penghasilan tiba-tiba berhenti."). */
    var summary: LocalizedStringResource {
        switch self {
        case .emergencyFund: "indicator.emergencyFund.summary"
        case .savingsRatio: "indicator.savingsRatio.summary"
        case .instalmentRatio: "indicator.instalmentRatio.summary"
        case .consumerDebt: "indicator.consumerDebt.summary"
        case .debtToAsset: "indicator.debtToAsset.summary"
        case .protection: "indicator.protection.summary"
        }
    }

    /** The formula in words, the heading of "Rumusnya". */
    var formulaTitle: LocalizedStringResource {
        switch self {
        case .emergencyFund: "indicator.emergencyFund.formula"
        case .savingsRatio: "indicator.savingsRatio.formula"
        case .instalmentRatio: "indicator.instalmentRatio.formula"
        case .consumerDebt: "indicator.consumerDebt.formula"
        case .debtToAsset: "indicator.debtToAsset.formula"
        case .protection: "indicator.protection.formula"
        }
    }

    /** Where the numbers come from, under the formula. */
    var source: LocalizedStringResource {
        switch self {
        case .emergencyFund: "indicator.emergencyFund.source"
        case .savingsRatio: "indicator.savingsRatio.source"
        case .instalmentRatio: "indicator.instalmentRatio.source"
        case .consumerDebt: "indicator.consumerDebt.source"
        case .debtToAsset: "indicator.debtToAsset.source"
        case .protection: "indicator.protection.source"
        }
    }

    /** "Kenapa Ini Penting"; the emergency fund's names its target (`IndicatorWhy`). */
    var why: LocalizedStringResource {
        switch self {
        case .emergencyFund: "indicator.emergencyFund.why"
        case .savingsRatio: "indicator.savingsRatio.why"
        case .instalmentRatio: "indicator.instalmentRatio.why"
        case .consumerDebt: "indicator.consumerDebt.why"
        case .debtToAsset: "indicator.debtToAsset.why"
        case .protection: "indicator.protection.why"
        }
    }

    /** The handwritten note on "Aturan Nilai" while a rung is left to climb. */
    var ladderNote: LocalizedStringResource {
        self == .emergencyFund ? "indicator.ladder.noteOneMore" : "indicator.ladder.noteLastOne"
    }
}

extension IndicatorGroup {
    /** "Tabung", "Utang", "Lindungi". */
    var name: LocalizedStringResource {
        switch self {
        case .save: "indicator.group.save"
        case .debt: "indicator.group.debt"
        case .protect: "indicator.group.protect"
        }
    }

    /** "Kelompok Tabung", the detail's subtitle. */
    var groupTitle: LocalizedStringResource {
        switch self {
        case .save: "indicator.group.save.title"
        case .debt: "indicator.group.debt.title"
        case .protect: "indicator.group.protect.title"
        }
    }

    /** The tile of the group's card. */
    var category: KiraCategory {
        switch self {
        case .save: .savings
        case .debt: .paylater
        case .protect: .protection
        }
    }
}
