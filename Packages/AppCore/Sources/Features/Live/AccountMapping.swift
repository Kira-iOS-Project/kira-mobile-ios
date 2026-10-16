import APIClient
import Domain

/** The account's answers in the Domain's values (`GET /me`, consents). */
extension AccountProfile {
    /** The person as `GET /me` and `PATCH /me` return them. */
    init(_ me: MeDTO) throws {
        self.init(
            id: me.id, email: me.email, displayName: me.displayName,
            plan: AccountPlan(
                id: me.plan.id, source: try me.plan.source.map { try Bridge.value($0) },
                renewsOn: try me.plan.renewsOn.map { try Bridge.day($0).date }),
            usage: try AccountUsage(me.usage), period: try Bridge.period(me.period),
            debtAccountCount: me.debtAccountCount, hidesBalances: me.hideBalances, aiEnabled: me.aiEnabled,
            weeklySummaryEnabled: me.weeklySummaryEnabled)
    }
}

extension AccountUsage {
    /** The plan's quotas this period and the day they reset. */
    init(_ usage: UsageDTO) throws {
        self.init(
            aiMessages: UsageMeter(used: usage.aiMessages.used, limit: usage.aiMessages.limit),
            receipts: UsageMeter(used: usage.receipts.used, limit: usage.receipts.limit),
            voiceSeconds: UsageMeter(used: usage.voiceSeconds.used, limit: usage.voiceSeconds.limit),
            resetsOn: try Bridge.day(usage.resetsOn).date)
    }
}

extension ConsentSettings {
    /** The consents in force under the policy version. */
    init(_ consents: ConsentsDTO) throws {
        self.init(
            policyVersion: consents.policyVersion,
            items: try consents.items.map {
                ConsentItem(purpose: try Bridge.value($0.purpose), granted: $0.granted, decidedAt: $0.decidedAt)
            })
    }
}
