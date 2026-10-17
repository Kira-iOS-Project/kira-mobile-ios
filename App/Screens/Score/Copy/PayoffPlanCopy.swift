/** The phrases of Rencanaku and Perayaan Lunas that depend on the plan's numbers, word for word from the boards. */
import Domain
import Features
import Foundation

enum PayoffPlanCopy {
    /** "Snowball · mulai Oktober 2026", under the title. */
    static func subtitle(_ plan: ActivePayoffPlan) -> LocalizedStringResource {
        let start = plan.startedAt.formatted(.kiraMonthYear)
        return switch plan.method {
        case .snowball: "plan.subtitle.snowball \(start)"
        case .avalanche: "plan.subtitle.avalanche \(start)"
        }
    }

    /** "Paylater A lunas dalam 10 hari": the hero's line for the account in progress. */
    static func headline(_ account: PlanAccount, countdown: PayoffCountdown) -> LocalizedStringResource {
        switch countdown {
        case .days(0): "plan.hero.today \(account.name)"
        case .days(let days): "plan.hero.days \(account.name) \(days)"
        case .date(let iso): when(account, date(iso))
        case .month(let iso): when(account, PayoffCopy.month(iso))
        case .unknown: "plan.hero.unknown \(account.name)"
        }
    }

    /** "Paylater B lunas 5 Januari 2027"; the plain line when the date cannot be read. */
    private static func when(_ account: PlanAccount, _ text: String?) -> LocalizedStringResource {
        guard let text else { return "plan.hero.unknown \(account.name)" }
        return "plan.hero.on \(account.name) \(text)"
    }

    /** "Rp840.000,00 dari Rp1.260.000,00", under the hero's ribbon. */
    static func paidCaption(_ account: PlanAccount) -> LocalizedStringResource {
        "plan.hero.caption \(PayoffCopy.rupiah(account.paid)) \(PayoffCopy.rupiah(account.original))"
    }

    /** "10 Hari Lagi" on the next payment; nil without a due day. */
    static func daysLeft(_ payment: NextPayment) -> LocalizedStringResource? {
        guard let left = payment.daysLeft else { return nil }
        return left <= 0 ? "plan.next.today" : "plan.next.daysLeft \(left)"
    }

    /** "Paylater A · 25 Oktober 2026", or the name alone without a due date. */
    static func payee(_ payment: NextPayment) -> LocalizedStringResource {
        guard let date = date(payment.dueDate) else { return "\(payment.name)" }
        return "plan.next.dated \(payment.name) \(date)"
    }

    /** "Lunas 25 Oktober 2026", or "Lunas November 2027" without a due day; nil when the plan cannot say. */
    static func payoff(_ account: PlanAccount) -> LocalizedStringResource? {
        guard let when = date(account.payoffDate) ?? PayoffCopy.month(account.payoffMonth) else { return nil }
        return "plan.account.payoff \(when)"
    }

    /** The tag of an account: "Berikutnya · November" names the month the plan reaches it. */
    static func tag(_ account: PlanAccount) -> LocalizedStringResource {
        switch account.status {
        case .inProgress: return "plan.tag.inProgress"
        case .next:
            guard let iso = account.startMonth, let day = CalendarDay(iso: "\(iso)-01") else { return "plan.tag.next" }
            return "plan.tag.next.month \(day.date.formatted(.kiraMonth))"
        case .ongoing: return "plan.tag.ongoing"
        case .paidOff: return "plan.tag.paidOff"
        }
    }

    /** "Akun 1 dari 3 selesai"; nil when the plan no longer lists the account. */
    static func position(_ paid: PaidOffAccount) -> LocalizedStringResource? {
        guard let position = paid.position else { return nil }
        return "plan.celebrate.position \(position) \(paid.total)"
    }

    /** "15 Oktober 2026" for a `YYYY-MM-DD`; nil when there is none or it cannot be read. */
    private static func date(_ iso: String?) -> String? {
        guard let iso, let day = CalendarDay(iso: iso) else { return nil }
        return day.date.formatted(.kiraDate)
    }
}
