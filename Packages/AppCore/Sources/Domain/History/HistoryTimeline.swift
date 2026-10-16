/**
 How Riwayat lays out a pay period (CAT-07): one group per WIB day, newest first, each with the
 engine's totals for its footer. The two newest days show; the days between them and payday fold
 into one "Tampilkan …" button until the person opens them; the payday group closes the list.
 */

/** One day of the history with its transactions and totals. */
package struct HistoryDay: Identifiable, Hashable, Sendable {
    /** What the day is to the person, which its title says. */
    package enum Kind: Hashable, Sendable {
        /** "Hari Ini · Kamis 15 Oktober 2026". */
        case today
        /** The first day of the pay period: "Jumat 25 September 2026 · Gajian". */
        case payday
        /** Any other day: "Rabu 14 Oktober 2026". */
        case past
    }

    package let day: CalendarDay
    package let kind: Kind
    package let transactions: [Transaction]
    package let totals: DayTotals

    package var id: CalendarDay { day }
}

/** A block of the history list. */
package enum HistorySection: Identifiable, Hashable, Sendable {
    /** A day's group. */
    case day(HistoryDay)
    /** The folded days, from the first to the last, newest last. */
    case olderDays(from: CalendarDay, to: CalendarDay)

    package var id: String {
        switch self {
        case .day(let day): "day-\(day.day.iso)"
        case .olderDays(let from, _): "older-\(from.iso)"
        }
    }
}

/** Groups transactions by day and folds the older days. */
package enum HistoryTimeline {
    /** How many of the newest days show while the older ones are folded. */
    package static let recentDayCount = 2

    /** The days that hold transactions, newest first, each with its totals from `summary`. */
    package static func days(
        _ transactions: [Transaction], summary: TransactionSummary, period: PayPeriod, today: CalendarDay
    ) -> [HistoryDay] {
        let byDay = Dictionary(grouping: transactions, by: \.day).sorted { $0.key > $1.key }
        return byDay.map { day, transactions in
            let items = transactions.sorted { $0.occurredAt > $1.occurredAt }
            let kind: HistoryDay.Kind = day == today ? .today : (day == period.start ? .payday : .past)
            return HistoryDay(day: day, kind: kind, transactions: items, totals: summary.totals(on: day))
        }
    }

    /**
     The list as it shows: every day when `isExpanded`, else the newest days, the folded range,
     and the payday group when it is loaded. Nothing folds when nothing would hide.
     */
    package static func sections(_ days: [HistoryDay], period: PayPeriod, isExpanded: Bool) -> [HistorySection] {
        let payday = days.last { $0.day == period.start && $0.kind == .payday }
        let others = days.filter { $0.day != payday?.day }
        guard !isExpanded, others.count > recentDayCount else { return days.map(HistorySection.day) }
        let recent = others.prefix(recentDayCount)
        let oldestShown = recent[recent.index(before: recent.endIndex)].day
        let from = payday == nil ? period.start : period.start.adding(days: 1)
        var sections = recent.map(HistorySection.day)
        sections.append(.olderDays(from: from, to: oldestShown.adding(days: -1)))
        if let payday { sections.append(.day(payday)) }
        return sections
    }
}
