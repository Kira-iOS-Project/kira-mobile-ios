/**
 Values more than one tag returns: a plan's usage this quota period, a payday and the payday
 period a date falls in. Dates are `YYYY-MM-DD` strings in WIB, as the API sends them.
 */

/** How much of one plan allowance is used. */
package struct UsageMeterDTO: Hashable, Sendable {
    /** Used so far this quota period. */
    package let used: Int
    /** The plan's allowance; 0 when the plan has none. */
    package let limit: Int

    init(_ meter: Components.Schemas.UsageMeter) {
        used = meter.used
        limit = meter.limit
    }
}

/** The AI-backed inputs used this quota period, and when they reset. */
package struct UsageDTO: Hashable, Sendable {
    /** Chat messages read by Kira AI. */
    package let aiMessages: UsageMeterDTO
    /** Receipts scanned. */
    package let receipts: UsageMeterDTO
    /** Seconds of voice input. */
    package let voiceSeconds: UsageMeterDTO
    /** The date the counters start again (`YYYY-MM-DD`). */
    package let resetsOn: String

    init(_ usage: Components.Schemas.Usage) {
        aiMessages = UsageMeterDTO(usage.aiMessages)
        receipts = UsageMeterDTO(usage.receipts)
        voiceSeconds = UsageMeterDTO(usage.voiceSeconds)
        resetsOn = usage.resetsOn
    }
}

/** Tanggal gajian: a day of the month, the last day of every month, or not set. */
package struct PaydayDTO: Hashable, Sendable {
    /** The day of the month, 1–31, or nil. */
    package let day: Int?
    /** Paid on the last day of every month. */
    package let endOfMonth: Bool

    /** A payday to send. */
    package init(day: Int?, endOfMonth: Bool) {
        self.day = day
        self.endOfMonth = endOfMonth
    }

    /** Whether a payday was chosen at all. */
    package var isSet: Bool { day != nil || endOfMonth }
}

/** The budget period today falls in, from one payday to the day before the next. */
package struct PaydayPeriodDTO: Hashable, Sendable {
    /** The payday the period began on. */
    package let start: String
    /** The day before the next payday. */
    package let end: String
    /** The next payday. */
    package let nextPayday: String
    /** Days from today until the next payday ("gajian 10 hari lagi"). */
    package let daysUntilPayday: Int

    init(start: String, end: String, nextPayday: String, daysUntilPayday: Int) {
        self.start = start
        self.end = end
        self.nextPayday = nextPayday
        self.daysUntilPayday = daysUntilPayday
    }

    init(_ period: Components.Schemas.PaydayPeriod) {
        self.init(
            start: period.start, end: period.end, nextPayday: period.nextPayday,
            daysUntilPayday: period.daysUntilPayday)
    }
}
