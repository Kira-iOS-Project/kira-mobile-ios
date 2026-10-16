import Foundation

/** What the plan's AI quota allows this period, and how much is used: the API's `Usage`. */
package struct AccountUsage: Equatable, Sendable {
    /** Chat AI messages. */
    package let aiMessages: UsageMeter
    /** Scanned receipts. */
    package let receipts: UsageMeter
    /** Seconds of voice input (Kira Plus). */
    package let voiceSeconds: UsageMeter
    /** The day the quota fills again. */
    package let resetsOn: Date

    /** A quota with every meter given. */
    package init(aiMessages: UsageMeter, receipts: UsageMeter, voiceSeconds: UsageMeter, resetsOn: Date) {
        self.aiMessages = aiMessages
        self.receipts = receipts
        self.voiceSeconds = voiceSeconds
        self.resetsOn = resetsOn
    }
}
