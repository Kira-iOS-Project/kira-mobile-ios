/**
 The words of "Aturan Nilai" and of the next-rung card: each rung's title and range, and what the
 next rung takes, written from the engine's amounts.
 */
import Domain
import SwiftUI

extension IndicatorDetail {
    /**
     A rung's title ("1× sampai Separuh Target"). The rungs are the engine's fixed rules, so the
     key is looked up by indicator and points (manual catalog keys `indicator.rung.<key>.<points>`).
     */
    func title(of rung: LadderRung) -> Text {
        Text(LocalizedStringKey(rungKey(of: rung)))
    }

    /**
     The catalog key of a rung. Four or more consumer-debt platforms, all paid on time, also score 25,
     the points of "Ada Keterlambatan"; the rung they stand on then says so instead of a lateness
     that never happened (`.onTime` variant of the key).
     */
    private func rungKey(of rung: LadderRung) -> String {
        let key = "indicator.rung.\(indicator.key.rawValue).\(rung.points)"
        guard indicator.key == .consumerDebt, rung.points == 25, rung.isCurrent else { return key }
        return indicator.measure.payment == .onTime ? "\(key).onTime" : key
    }

    /** A rung's second line, from its range and amounts. */
    func detail(of rung: LadderRung) -> Text {
        let isMultiple = indicator.key == .emergencyFund
        switch range(of: rung) {
        case .fixed:
            let key = rungKey(of: rung) + ".detail"
            return Text(LocalizedStringKey(key))
        case .atLeast(let bound) where isMultiple:
            return Text(
                "indicator.range.multipleAtLeast \(multiple(bound.multiple)) \(bound.amount.rupiah, format: .rupiah)")
        case .from(let bound) where isMultiple:
            return Text(
                "indicator.range.multipleFrom \(multiple(bound.multiple)) \(bound.amount.rupiah, format: .rupiah)")
        case .atLeast(let bound): return Text("indicator.range.atLeast \(bound.amount.rupiah, format: .rupiah)")
        case .from(let bound): return Text("indicator.range.from \(bound.amount.rupiah, format: .rupiah)")
        case .under(let amount): return Text("indicator.range.under \(amount.rupiah, format: .rupiah)")
        case .between(let lower, let upper):
            return Text("indicator.range.between \(lower.rupiah, format: .rupiah) \(upper.rupiah, format: .rupiah)")
        case .over(let amount): return Text("indicator.range.over \(amount.rupiah, format: .rupiah)")
        }
    }

    private func multiple(_ value: Double) -> Text { Text(value, format: .kiraMultiple) }

    /** What the next rung takes, in one sentence. */
    func nextRungMessage(_ next: NextRung) -> LocalizedStringResource {
        let rung = nextRungTarget
        let needed = (next.amountNeeded ?? 0).rupiah
        let upper = Int(rung?.upper ?? 0)
        let amountUpper = (rung?.amountUpper ?? 0).rupiah
        switch indicator.measure {
        case .emergencyFund:
            let lower = rung?.lower ?? 0
            return next.points == 75
                ? "indicator.next.emergencyFundHalf \(needed, format: .rupiah) \(lower, format: .kiraMultiple)"
                : "indicator.next.emergencyFund \(needed, format: .rupiah) \(lower, format: .kiraMultiple)"
        case .savingsRatio(_, let savings, _):
            let current = savings.rupiah
            let percent = Int(rung?.lower ?? 0)
            return "indicator.next.savings \(current, format: .rupiah) \(current + needed, format: .rupiah) \(percent)"
        case .instalmentRatio:
            return "indicator.next.instalment \(upper) \(amountUpper, format: .rupiah)"
        case .debtToAsset:
            return next.points == 100
                ? "indicator.next.debtToAssetBelow \(upper) \(amountUpper, format: .rupiah)"
                : "indicator.next.debtToAsset \(upper) \(amountUpper, format: .rupiah)"
        case .consumerDebt:
            return consumerNext(next.points)
        case .protectionCover:
            return protectionNext(indicator.measure.coverage)
        }
    }

    /**
     What the next consumer-debt rung takes. Reaching 50 asks a late payer to pay on time first; four
     or more platforms already paid on time only need paying off down to three.
     */
    private func consumerNext(_ points: Int) -> LocalizedStringResource {
        switch (points, indicator.measure.payment) {
        case (100, _): "indicator.next.consumerDebtLast"
        case (75, _): "indicator.next.consumerDebtOne"
        case (50, .onTime): "indicator.next.consumerDebtMany"
        case (50, _): "indicator.next.consumerDebtOnTime"
        default: "indicator.next.consumerDebtOverdue"
        }
    }

    private func protectionNext(_ coverage: Coverage) -> LocalizedStringResource {
        switch coverage {
        case .healthOnly: "indicator.next.protectionIncome"
        case .incomeOnly: "indicator.next.protectionHealth"
        case .both, .neither: "indicator.next.protectionStart"
        }
    }

    /** The next-rung card's primary button. */
    var nextRungLabel: LocalizedStringResource {
        switch indicator.key {
        case .emergencyFund, .savingsRatio: "indicator.next.setDeposit"
        case .instalmentRatio, .consumerDebt, .debtToAsset: "step.openPlan"
        case .protection: "indicator.next.checkAgain"
        }
    }

    /** "Kenapa Ini Penting": the emergency fund names its own target. */
    var why: LocalizedStringResource {
        guard case .emergencyFund(_, _, _, let target, _) = indicator.measure, target != 6 else {
            return indicator.key.why
        }
        return "indicator.emergencyFund.whyTarget \(target)"
    }
}
