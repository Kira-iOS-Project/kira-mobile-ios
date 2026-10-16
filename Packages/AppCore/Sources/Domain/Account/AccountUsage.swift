import Foundation

/** What the plan's AI quota allows this period, and how much is used: the API's `Usage`. */
package struct AccountUsage: Equatable, Sendable {
    package let aiMessages: UsageMeter
    package let receipts: UsageMeter
    package let voiceSeconds: UsageMeter
    /** The day the quota fills again. */
    package let resetsOn: Date

    package init(aiMessages: UsageMeter, receipts: UsageMeter, voiceSeconds: UsageMeter, resetsOn: Date) {
        self.aiMessages = aiMessages
        self.receipts = receipts
        self.voiceSeconds = voiceSeconds
        self.resetsOn = resetsOn
    }
}

/** One quota: how many are used out of the limit. A full meter never blocks manual entry. */
package struct UsageMeter: Equatable, Sendable {
    package let used: Int
    package let limit: Int

    package init(used: Int, limit: Int) {
        self.used = used
        self.limit = limit
    }
}
