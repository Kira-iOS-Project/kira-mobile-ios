/**
 What an indicator measured, in words: its value ("1,1× pengeluaran pokok"), its target in the
 list ("target 6×"), and the line under the value in "Posisimu", chosen by `IndicatorPosition`.
 */
import Domain
import SwiftUI

extension IndicatorMeasure {
    /** The value as "Posisimu" titles it. */
    var valueText: Text {
        switch self {
        case .emergencyFund(let ratio, _, _, _, _):
            Text("indicator.emergencyFund.value \(Text(ratio, format: .kiraDecimal(1)))")
        case .savingsRatio(let percent, _, _), .instalmentRatio(let percent, _, _):
            Text("indicator.ofIncome \(percent)")
        case .debtToAsset(let percent, _, _): Text("indicator.ofAssets \(percent)")
        case .consumerDebt(0, _, _): Text("indicator.consumerDebt.none")
        case .consumerDebt(let platforms, _, _): Text("indicator.consumerDebt.value \(platforms)")
        case .protectionCover:
            switch coverage {
            case .both: Text("indicator.protection.both")
            case .healthOnly: Text("indicator.protection.healthOnly")
            case .incomeOnly: Text("indicator.protection.incomeOnly")
            case .neither: Text("indicator.protection.neither")
            }
        }
    }

    /** The value as the indicator list writes it, with the payment or the covers spelled out. */
    var rowValue: Text {
        switch self {
        case .consumerDebt(let platforms, _, _) where platforms > 0:
            switch payment {
            case .onTime: Text("indicator.consumerDebt.row.onTime \(platforms)")
            case .late: Text("indicator.consumerDebt.row.late \(platforms)")
            case .overdue: Text("indicator.consumerDebt.row.overdue \(platforms)")
            }
        case .protectionCover:
            switch coverage {
            case .both: Text("indicator.protection.row.both")
            case .healthOnly: Text("indicator.protection.row.healthOnly")
            case .incomeOnly: Text("indicator.protection.row.incomeOnly")
            case .neither: Text("indicator.protection.row.neither")
            }
        default: valueText
        }
    }

    /** The line under the value in "Posisimu". */
    var positionText: Text {
        switch self {
        case .emergencyFund(_, _, _, let target, _): fundLine(target: target)
        case .savingsRatio: savingsLine
        case .instalmentRatio:
            limitLine(
                LimitKeys(
                    within: "indicator.instalmentRatio.within", over: "indicator.instalmentRatio.over",
                    nothing: "indicator.instalmentRatio.nothing", missing: "indicator.missingIncome"))
        case .debtToAsset:
            limitLine(
                LimitKeys(
                    within: "indicator.debtToAsset.within", over: "indicator.debtToAsset.over",
                    nothing: "indicator.debtToAsset.nothing", missing: "indicator.missingAssets"))
        case .consumerDebt: consumerLine
        case .protectionCover: protectionLine
        }
    }

    private func fundLine(target: Int) -> Text {
        switch position {
        case .monthsCovered(1): Text("indicator.emergencyFund.oneMonth")
        case .monthsCovered(let months): Text("indicator.emergencyFund.months \(months)")
        case .reachedGoal: Text("indicator.emergencyFund.reached \(target)")
        case .missingBase: Text("indicator.emergencyFund.missing")
        default: Text("indicator.emergencyFund.short")
        }
    }

    private var savingsLine: Text {
        switch position {
        case .betweenGoals: Text("indicator.savingsRatio.between")
        case .reachedGoal: Text("indicator.savingsRatio.reached")
        case .missingBase: Text("indicator.missingIncome")
        default: Text("indicator.savingsRatio.below")
        }
    }

    private func limitLine(_ keys: LimitKeys) -> Text {
        switch position {
        case .overLimit: Text(keys.over)
        case .nothingOwed: Text(keys.nothing)
        case .missingBase: Text(keys.missing)
        default: Text(keys.within)
        }
    }

    private var consumerLine: Text {
        switch position {
        case .nothingOwed: Text("indicator.consumerDebt.cleared")
        case .belowGoal: Text("indicator.consumerDebt.late")
        case .overLimit: Text("indicator.consumerDebt.overdue")
        default: consumerOnTimeLine
        }
    }

    /** All paid on time: four or more platforms still score 25 (KIR-126), so the line says why. */
    private var consumerOnTimeLine: Text {
        guard case .consumerDebt(let platforms, _, _) = self, platforms >= 4 else {
            return Text("indicator.consumerDebt.onTime")
        }
        return Text("indicator.consumerDebt.onTimeMany")
    }

    private var protectionLine: Text {
        switch coverage {
        case .both: Text("indicator.protection.line.both")
        case .healthOnly: Text("indicator.protection.line.healthOnly")
        case .incomeOnly: Text("indicator.protection.line.incomeOnly")
        case .neither: Text("indicator.protection.line.neither")
        }
    }
}

/** The four lines of a less-is-better ratio. */
private struct LimitKeys {
    let within: LocalizedStringKey
    let over: LocalizedStringKey
    let nothing: LocalizedStringKey
    let missing: LocalizedStringKey
}

extension IndicatorTarget {
    /** "target 6×", "minimal 10%", "batas 30%". */
    var text: Text {
        switch self {
        case .multiple(let multiple): Text("indicator.target.multiple \(multiple)")
        case .minimumPercent(let percent): Text("indicator.target.minimum \(percent)")
        case .targetPercent(let percent): Text("indicator.target.percent \(percent)")
        case .limitPercent(let percent): Text("indicator.target.limit \(percent)")
        }
    }
}
