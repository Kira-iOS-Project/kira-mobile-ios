/** The month's use of each quota (`Usage` in the API), shown on Langganan. */
package struct PlanUsage: Hashable, Sendable {
    /** How much of one quota is used. */
    package struct Quota: Hashable, Sendable {
        /** Used so far this period. */
        package let used: Int
        /** The plan's limit. */
        package let limit: Int

        /** A quota as the API sends it. */
        package init(used: Int, limit: Int) {
            self.used = used
            self.limit = limit
        }
    }

    /** Chat messages Kira read. */
    package let aiMessages: Quota
    /** Receipts Kira read. */
    package let receipts: Quota
    /** Seconds of voice input. */
    package let voiceSeconds: Quota
    /** The day the quotas fill up again. */
    package let resetsOn: CalendarDay

    /** The usage as the API sends it. */
    package init(aiMessages: Quota, receipts: Quota, voiceSeconds: Quota, resetsOn: CalendarDay) {
        self.aiMessages = aiMessages
        self.receipts = receipts
        self.voiceSeconds = voiceSeconds
        self.resetsOn = resetsOn
    }
}
