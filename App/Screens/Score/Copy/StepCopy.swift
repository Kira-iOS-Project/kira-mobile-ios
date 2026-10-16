/**
 The words of a score step, built from the engine's numbers: its title, its one sentence, its
 illustration and tile, and the buttons that open it. Beranda's NextStepCard and the score's
 "Tiga Langkah Prioritas" use the same words.
 */
import Domain
import SwiftUI

extension ScoreStep {
    /** "Lunasi Paylater A", "Dana Darurat ke 3×", "Menabung 10% dari Gaji". */
    var title: LocalizedStringResource {
        switch kind {
        case .payOffDebt:
            debtName.map { "step.payOffDebt.title \($0)" } ?? "step.payOffDebt.titleUnnamed"
        case .seekRelief:
            debtName.map { "step.seekRelief.title \($0)" } ?? "step.seekRelief.titleUnnamed"
        case .buildEmergencyFund: "step.buildEmergencyFund.title \(targetMultiple ?? 0)"
        case .raiseSavings: "step.raiseSavings.title \(targetPercent ?? 0)"
        case .addProtection: "step.addProtection.title"
        case .lowerInstalments: "step.lowerInstalments.title \(targetPercent ?? 0)"
        case .lowerDebtToAsset: "step.lowerDebtToAsset.title \(targetPercent ?? 0)"
        }
    }

    /** The sentence under the title, its amounts hidden when `masked`. */
    func message(masked: Bool) -> LocalizedStringResource {
        let money = RupiahFormatStyle.rupiah.masked(masked)
        let current = (currentAmount ?? 0).rupiah
        let target = (targetAmount ?? 0).rupiah
        switch kind {
        case .payOffDebt: return "step.payOffDebt.message \((remaining ?? 0).rupiah, format: money)"
        case .seekRelief: return "step.seekRelief.message"
        case .buildEmergencyFund:
            return "step.buildEmergencyFund.message \(shortfall.rupiah, format: money) \(target, format: money)"
        case .raiseSavings, .lowerInstalments:
            return "step.monthly.message \(current, format: money) \(target, format: money)"
        case .lowerDebtToAsset: return "step.lowerDebtToAsset.message \(current, format: money) \(target, format: money)"
        case .addProtection: return "step.addProtection.message"
        }
    }

    /** The spot illustration of Beranda's card. */
    var illustration: KiraIllustrationName {
        switch kind {
        case .payOffDebt, .seekRelief, .lowerInstalments, .lowerDebtToAsset: .cardPaidOff
        case .buildEmergencyFund, .raiseSavings: .piggyBank
        case .addProtection: .umbrella
        }
    }

    /** The tile of the score's step list. */
    var category: KiraCategory {
        switch kind {
        case .payOffDebt, .lowerInstalments: .paylater
        case .seekRelief: .onlineLoan
        case .buildEmergencyFund: .savings
        case .raiseSavings: .salary
        case .addProtection: .protection
        case .lowerDebtToAsset: .bank
        }
    }

    /** Beranda's primary button: "Lihat Rencana", "Lihat Naskah" or "Lihat Detail". */
    var primaryLabel: LocalizedStringResource {
        switch kind {
        case .payOffDebt: "step.openPlan"
        case .seekRelief: "step.openScript"
        default: "step.openDetail"
        }
    }

    /** Where the step leads, said after its title by VoiceOver ("Lihat Rencana Pelunasan"). */
    var destinationLabel: Text {
        switch kind {
        case .payOffDebt: Text("step.destination.plan")
        case .seekRelief: Text("step.openScript")
        case .buildEmergencyFund: Text("step.destination.detail \(Text(IndicatorKey.emergencyFund.name))")
        case .raiseSavings: Text("step.destination.detail \(Text(IndicatorKey.savingsRatio.name))")
        case .addProtection: Text("step.destination.detail \(Text(IndicatorKey.protection.name))")
        case .lowerInstalments: Text("step.destination.detail \(Text(IndicatorKey.instalmentRatio.name))")
        case .lowerDebtToAsset: Text("step.destination.detail \(Text(IndicatorKey.debtToAsset.name))")
        }
    }
}
