/**
 One plan allowance and how much of it is used this quota period (the API's `UsageMeter`): chat
 messages, receipts or seconds of voice. A full meter never blocks manual entry.
 */
package struct UsageMeter: Hashable, Sendable {
    /** How many are used this period. */
    package let used: Int
    /** How many the plan allows; 0 when the plan has none. */
    package let limit: Int

    /** A meter of `used` out of `limit`. */
    package init(used: Int, limit: Int) {
        self.used = used
        self.limit = limit
    }

    /** What is left, never below zero. */
    package var remaining: Int { max(0, limit - used) }

    /** Whether nothing is left. */
    package var isExhausted: Bool { used >= limit }
}
