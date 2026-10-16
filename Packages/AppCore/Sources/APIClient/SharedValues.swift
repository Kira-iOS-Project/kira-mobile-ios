/**
 Values more than one tag returns: a plan's usage this quota period and the payday period a
 date falls in. The meter itself is Domain's `UsageMeter`, and a payday is Domain's `Payday`.
 Dates are `YYYY-MM-DD` strings in WIB, as the API sends them.
 */
import Domain

extension UsageMeter {
    /** The API's meter as the Domain value. */
    init(_ meter: Components.Schemas.UsageMeter) {
        self.init(used: meter.used, limit: meter.limit)
    }
}

/** The AI-backed inputs used this quota period, and when they reset. */
package struct Usage: Hashable, Sendable {
    /** Chat messages read by Kira AI. */
    package let aiMessages: UsageMeter
    /** Receipts scanned. */
    package let receipts: UsageMeter
    /** Seconds of voice input. */
    package let voiceSeconds: UsageMeter
    /** The date the counters start again (`YYYY-MM-DD`). */
    package let resetsOn: String

    init(_ usage: Components.Schemas.Usage) {
        aiMessages = UsageMeter(usage.aiMessages)
        receipts = UsageMeter(usage.receipts)
        voiceSeconds = UsageMeter(usage.voiceSeconds)
        resetsOn = usage.resetsOn
    }
}

/** The budget period today falls in, from one payday to the day before the next. */
package struct PaydayPeriod: Hashable, Sendable {
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
