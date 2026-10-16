import APIClient
import Domain

extension Usage {
    /** The plan's quotas this period and the day they reset (`Me.usage`, `Subscription.usage`). */
    init(_ usage: UsageDTO) throws {
        self.init(
            aiMessages: UsageMeter(used: usage.aiMessages.used, limit: usage.aiMessages.limit),
            receipts: UsageMeter(used: usage.receipts.used, limit: usage.receipts.limit),
            voiceSeconds: UsageMeter(used: usage.voiceSeconds.used, limit: usage.voiceSeconds.limit),
            resetsOn: try Bridge.day(usage.resetsOn))
    }
}
