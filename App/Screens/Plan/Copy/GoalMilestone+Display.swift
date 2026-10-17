/**
 The emergency fund's milestones in words (REN-05): their labels under the bar ("1 minggu",
 "1 bulan", "3×", "6×"), and the celebration card's title and line once one is reached. The board
 draws the one-month card; the others follow its pattern.
 */
import Domain
import SwiftUI

extension GoalMilestone {
    /** The label under the progress bar; the target names its multiple ("6×") when it is known. */
    func label(targetMultiple: Double?) -> LocalizedStringResource {
        switch key {
        case .oneWeek: "plan.milestone.oneWeek"
        case .oneMonth: "plan.milestone.oneMonth"
        case .threeMonths: "plan.milestone.threeMonths"
        case .target:
            targetMultiple.map { "plan.milestone.multiple \($0, format: .kiraMultiple)" } ?? "plan.milestone.target"
        }
    }

    /** "Tonggak 1 Bulan Tercapai". */
    var reachedTitle: LocalizedStringResource {
        switch key {
        case .oneWeek: "plan.milestone.oneWeek.reached"
        case .oneMonth: "plan.milestone.oneMonth.reached"
        case .threeMonths: "plan.milestone.threeMonths.reached"
        case .target: "plan.milestone.target.reached"
        }
    }

    /** "Sebulan kebutuhan pokok aman." */
    var reachedLine: LocalizedStringResource {
        switch key {
        case .oneWeek: "plan.milestone.oneWeek.line"
        case .oneMonth: "plan.milestone.oneMonth.line"
        case .threeMonths: "plan.milestone.threeMonths.line"
        case .target: "plan.milestone.target.line"
        }
    }
}
