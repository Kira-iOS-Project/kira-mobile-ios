/**
 The words of a priority step, written from the engine's numbers (HasilCekAwal: "Lunasi Paylater
 A", "Sisa Rp420.000,00. Utang terkecil dulu."). Money is formatted here, in the view.
 */
import Domain
import SwiftUI

struct ScoreStepCopy {
    let step: ScoreStep

    /** The step's title. */
    var title: Text {
        switch step.kind {
        case .payOffDebt: Text("onboarding.result.step.payOff \(step.debtName ?? "")")
        case .seekRelief: Text("onboarding.result.step.relief \(step.debtName ?? "")")
        case .buildEmergencyFund: Text("onboarding.result.step.fund \(step.targetMultiple ?? 0, format: .kiraMultiple)")
        case .addProtection: Text("onboarding.result.step.protection")
        case .raiseSavings: Text("onboarding.result.step.savings \(step.targetPercent ?? 0)")
        case .lowerInstalments: Text("onboarding.result.step.instalments \(step.targetPercent ?? 0)")
        case .lowerDebtToAsset: Text("onboarding.result.step.debtToAsset")
        }
    }

    /** The line under it. */
    var detail: Text {
        switch step.kind {
        case .payOffDebt: Text("onboarding.result.step.payOff.detail \(money(step.remaining))")
        case .seekRelief: Text("onboarding.result.step.relief.detail \(money(step.remaining))")
        case .buildEmergencyFund:
            Text("onboarding.result.step.fund.detail \(money(step.shortfall)) \(money(step.targetAmount))")
        case .addProtection: Text("onboarding.result.step.protection.detail")
        case .raiseSavings, .lowerInstalments:
            Text("onboarding.result.step.change.detail \(money(step.currentAmount)) \(money(step.targetAmount))")
        case .lowerDebtToAsset:
            Text("onboarding.result.step.debtToAsset.detail \(step.targetPercent ?? 0) \(money(step.targetAmount))")
        }
    }

    /** "+5 Poin". */
    var gain: LocalizedStringResource { "onboarding.result.step.gain \(step.estimatedGain)" }

    private func money(_ amount: Int?) -> Text {
        Text(Decimal(amount ?? 0), format: .rupiah)
    }
}
