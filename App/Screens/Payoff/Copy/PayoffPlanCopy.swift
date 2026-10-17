/** The phrases of Rencanaku and the celebration that depend on the plan's numbers. */
import Domain
import Foundation

enum PayoffPlanCopy {
    /** The tag of an account. */
    static func tag(_ status: PlanAccountStatus) -> LocalizedStringResource {
        switch status {
        case .paidOff: "plan.tag.paidOff"
        case .inProgress: "plan.tag.inProgress"
        case .next: "plan.tag.next"
        case .ongoing: "plan.tag.ongoing"
        }
    }

    /** The method and, when there is one, the extra payment, under the progress bar. */
    static func caption(method: PayoffMethod, extraPayment: Int) -> LocalizedStringResource {
        switch (method, extraPayment > 0) {
        case (.snowball, true): "plan.caption.snowball.extra \(PayoffCopy.rupiah(extraPayment))"
        case (.snowball, false): "plan.caption.snowball"
        case (.avalanche, true): "plan.caption.avalanche.extra \(PayoffCopy.rupiah(extraPayment))"
        case (.avalanche, false): "plan.caption.avalanche"
        }
    }

    /** When the next payment is due; nil when the account has no due day. */
    static func due(_ payment: NextPayment) -> LocalizedStringResource? {
        guard let iso = payment.dueDate, let day = CalendarDay(iso: iso), let left = payment.daysLeft else {
            return nil
        }
        if left <= 0 { return "plan.next.today" }
        return "plan.next.in \(day.date.formatted(.kiraDayMonth)) \(left)"
    }

    /** The share of an account already paid. */
    static func progress(_ account: PlanAccount) -> LocalizedStringResource {
        "plan.account.progress \(account.progressPercent)"
    }

    /** What the estimate says the score does. */
    static func score(_ estimate: ScoreEstimate) -> LocalizedStringResource {
        "plan.celebrate.score \(estimate.before) \(estimate.after)"
    }
}
