import APIClient
import Domain

/**
 Reads what the API sent into the Domain's values. The API and the Domain spell their vocabulary
 the same (`track_spending`, `pay_off_debt`), and dates are `YYYY-MM-DD` in WIB; anything this app
 cannot read is a problem without a code, as an undocumented answer is.
 */
enum Bridge {
    /** The Domain case spelled as `source`. */
    static func value<Source: RawRepresentable, Target: RawRepresentable>(_ source: Source) throws -> Target
    where Source.RawValue == String, Target.RawValue == String {
        guard let target = Target(rawValue: source.rawValue) else { throw AppProblem() }
        return target
    }

    /** The WIB day the API wrote as `YYYY-MM-DD`. */
    static func day(_ iso: String) throws -> CalendarDay {
        guard let day = CalendarDay(iso: iso) else { throw AppProblem() }
        return day
    }

    /** The pay period of `GET /me` and `GET /home`. */
    static func period(_ period: PaydayPeriodDTO) throws -> PayPeriod {
        PayPeriod(start: try day(period.start), end: try day(period.end), daysUntilPayday: period.daysUntilPayday)
    }
}
