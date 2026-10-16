/**
 The month's quotas and what is used of them: the API's `Usage` (`GET /usage`, `Me.usage`,
 `Subscription.usage`). AI chat messages and receipts on every plan, voice seconds on Kira Plus
 only. Catat, Profil and Langganan read the same value.
 */
package struct Usage: Hashable, Sendable {
    /** AI chat messages this period. */
    package let aiMessages: UsageMeter
    /** Receipts read this period. */
    package let receipts: UsageMeter
    /** Voice seconds this period (Kira Plus). */
    package let voiceSeconds: UsageMeter
    /** The day the meters start again (CAT-09: "Terisi lagi 1 November 2026"). */
    package let resetsOn: CalendarDay

    /** The quotas and their reset day. */
    package init(aiMessages: UsageMeter, receipts: UsageMeter, voiceSeconds: UsageMeter, resetsOn: CalendarDay) {
        self.aiMessages = aiMessages
        self.receipts = receipts
        self.voiceSeconds = voiceSeconds
        self.resetsOn = resetsOn
    }
}
