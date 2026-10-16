/**
 The formula of an indicator written out from its numbers ("Rp4.800.000,00 ÷ Rp4.200.000,00",
 "= 1,14× → ditulis 1,1×"), and the caption of its bar.
 */
import Domain
import SwiftUI

extension ScoreIndicator {
    /** The division, or the rule applied ("2 platform · tepat waktu"). */
    var formulaInput: Text {
        if let division = measure.division {
            let part = division.part.rupiah
            let whole = division.whole.rupiah
            return Text("indicator.formula.divide \(part, format: .rupiah) \(whole, format: .rupiah)")
        }
        if case .consumerDebt(let platforms, _, _) = measure {
            return Text("indicator.formula.platforms \(platforms) \(measure.payment.text)")
        }
        return Text("indicator.formula.covers")
    }

    /** The result and how it is written ("= 0,18 → ditulis 18%", "= 50 poin"). */
    var formulaResult: Text {
        let quotient = Text(measure.division?.quotient ?? 0, format: .kiraDecimal(2))
        switch measure {
        case .emergencyFund(let ratio, _, _, _, _):
            return Text("indicator.formula.multiple \(quotient) \(Text(ratio, format: .kiraDecimal(1)))")
        case .savingsRatio(let percent, _, _), .instalmentRatio(let percent, _, _), .debtToAsset(let percent, _, _):
            return Text("indicator.formula.percent \(quotient) \(percent)")
        case .consumerDebt:
            return Text("indicator.formula.points \(points)")
        case .protectionCover:
            return Text("indicator.formula.coverPoints \(measure.coverage.activeCount) \(points)")
        }
    }
}

extension ConsumerPayment {
    /** "tepat waktu", "ada keterlambatan", "menunggak". */
    var text: Text {
        switch self {
        case .onTime: Text("indicator.payment.onTime")
        case .late: Text("indicator.payment.late")
        case .overdue: Text("indicator.payment.overdue")
        }
    }
}

extension IndicatorRibbon {
    /** "Rp4.800.000,00 dari target Rp25.200.000,00", with "batas" and "per bulan" where they apply. */
    var caption: LocalizedStringResource {
        let value = value.rupiah
        let target = target.rupiah
        switch (isLimit, isMonthly) {
        case (false, false): return "indicator.ribbon.target \(value, format: .rupiah) \(target, format: .rupiah)"
        case (false, true): return "indicator.ribbon.targetMonthly \(value, format: .rupiah) \(target, format: .rupiah)"
        case (true, false): return "indicator.ribbon.limit \(value, format: .rupiah) \(target, format: .rupiah)"
        case (true, true): return "indicator.ribbon.limitMonthly \(value, format: .rupiah) \(target, format: .rupiah)"
        }
    }
}

extension Milestone {
    /** The milestone's label under the bar, as the engine wrote it ("3×", "10%"). */
    var ribbonMilestone: KiraProgressRibbon.Milestone {
        KiraProgressRibbon.Milestone(position: Double(amount), label: "indicator.milestone \(label)")
    }
}
