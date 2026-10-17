/**
 The days Rencana Pelunasan (SKR-03) writes: an account is paid off on its due day in its payoff
 month ("Lunas 25 Oktober 2026"), the next account starts getting the extra money the month after
 the one before it is paid off ("Mulai November"), and the minimum is every consumer account's
 instalment. Without a due day the screen writes the month alone.
 */
extension PayoffAccount {
    /** The day it is paid off; nil when it never is or its due day is unknown. */
    package var payoffDay: CalendarDay? {
        PayoffSchedule.day(month: payoffMonth, dueDay: dueDay)
    }
}

extension PayoffSimulation {
    /** The account the plan pays first ("Fokus Bulan Ini"); nil without a consumer account. */
    package var firstAccount: PayoffAccount? {
        accounts.first { $0.position == 1 }
    }

    /** The day the last account is paid off; nil unless all are, or when its due day is unknown. */
    package var allPaidDay: CalendarDay? {
        let last = accounts.last { $0.payoffMonth == allPaidMonth }
        return PayoffSchedule.day(month: allPaidMonth, dueDay: last?.dueDay)
    }

    /** The cicilan minimum: what the plan pays every month before the extra payment. */
    package var minimumInstalments: Int {
        accounts.reduce(0) { $0 + $1.monthlyInstalment }
    }

    /** The account the plan pays just before `account`; nil for the first. */
    package func previous(of account: PayoffAccount) -> PayoffAccount? {
        accounts.first { $0.position == account.position - 1 }
    }

    /** The first day of the month `account` starts getting the extra money; nil for the first, or unknown. */
    package func startMonth(of account: PayoffAccount) -> CalendarDay? {
        guard let month = previous(of: account)?.payoffMonth, let first = CalendarDay(iso: "\(month)-01") else {
            return nil
        }
        return first.adding(months: 1)
    }
}

/** Turns a `YYYY-MM` and a due day into a day, the due day kept inside the month. */
enum PayoffSchedule {
    /** The due day in `month`, or the month's last day when it is shorter; nil without both. */
    static func day(month: String?, dueDay: Int?) -> CalendarDay? {
        guard let month, let dueDay, let first = CalendarDay(iso: "\(month)-01") else { return nil }
        let length = CalendarDay.length(ofMonth: first.month, in: first.year)
        return CalendarDay(year: first.year, month: first.month, day: min(max(dueDay, 1), length))
    }
}
