/**
 The pay period a payday gives (Beranda's `paydayPeriod`, no holiday shift): from the payday on or
 before a day to the day before the next payday. A day past a short month's end is its last day;
 "Gajian di akhir bulan" is always the last day, February included.
 */
extension Payday {
    /** This payday in `month` of `year`. */
    package func day(inMonth month: Int, of year: Int) -> CalendarDay {
        let last = CalendarDay.length(ofMonth: month, in: year)
        return CalendarDay(year: year, month: month, day: min(day ?? last, last))
    }

    /** The period `today` falls in, with the days until the next payday. */
    package func period(containing today: CalendarDay) -> PayPeriod {
        let thisMonth = day(inMonth: today.month, of: today.year)
        let start = today < thisMonth ? payday(monthsAfter: -1, thisMonth) : thisMonth
        let next = payday(monthsAfter: 1, start)
        return PayPeriod(start: start, end: next.adding(days: -1), daysUntilPayday: today.days(to: next))
    }

    /** This payday `months` months from the month of `payday`. */
    private func payday(monthsAfter months: Int, _ payday: CalendarDay) -> CalendarDay {
        let month = CalendarDay(year: payday.year, month: payday.month, day: 1).adding(months: months)
        return day(inMonth: month.month, of: month.year)
    }
}
