import APIClient
import Domain

/** The account's answers in the Domain's values (`GET /me`, consents). */
extension AccountProfile {
    /** The person as `GET /me` and `PATCH /me` return them. */
    init(_ account: MeDTO) throws {
        self.init(
            id: account.id, email: account.email, displayName: account.displayName,
            plan: AccountPlan(
                id: account.plan.id, source: try account.plan.source.map { try Bridge.value($0) },
                renewsOn: try account.plan.renewsOn.map { try Bridge.day($0).date }),
            usage: try Usage(account.usage), period: try Bridge.period(account.period),
            debtAccountCount: account.debtAccountCount, hidesBalances: account.hideBalances,
            aiEnabled: account.aiEnabled,
            weeklySummaryEnabled: account.weeklySummaryEnabled)
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
