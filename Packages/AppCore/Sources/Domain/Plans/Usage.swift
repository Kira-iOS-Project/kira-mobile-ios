import Foundation

/**
 The month's quotas and what is used of them: the API's `Usage` (`GET /usage`, `Me.usage`). AI
 chat messages and receipts on every plan, voice seconds on Kira Plus only.
 */
package struct Usage: Hashable, Sendable {
    package let aiMessages: UsageCounter
    package let receipts: UsageCounter
    package let voiceSeconds: UsageCounter
    /** The day the counters start again (CAT-09: "Terisi lagi 1 November 2026"). */
    package let resetsOn: Date

    package init(aiMessages: UsageCounter, receipts: UsageCounter, voiceSeconds: UsageCounter, resetsOn: Date) {
        self.aiMessages = aiMessages
        self.receipts = receipts
        self.voiceSeconds = voiceSeconds
        self.resetsOn = resetsOn
    }
}

/** One quota: used of limit. */
package struct UsageCounter: Hashable, Sendable {
    package let used: Int
    package let limit: Int

    package init(used: Int, limit: Int) {
        self.used = used
        self.limit = limit
    }

    /** What is left, never below zero. */
    package var remaining: Int { max(0, limit - used) }

    /** Whether nothing is left. */
    package var isExhausted: Bool { used >= limit }
}
