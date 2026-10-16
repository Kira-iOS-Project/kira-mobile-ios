import APIClient
import Domain

/** The account's answers in the Domain's values (`GET /me`, consents). */
extension AccountProfile {
    /** The person as `GET /me` and `PATCH /me` return them. */
    init(_ account: MeDTO) throws {
        self.init(
            id: account.id, email: account.email, displayName: account.displayName,
            plan: AccountPlan(id: account.plan.id),
            usage: try Usage(account.usage), period: try Bridge.period(account.period),
            debtAccountCount: account.debtAccountCount, hidesBalances: account.hideBalances,
            aiEnabled: account.aiEnabled,
            weeklySummaryEnabled: account.weeklySummaryEnabled)
    }
}

extension ConsentSettings {
    /** The consents in force. */
    init(_ consents: ConsentsDTO) throws {
        self.init(
            items: try consents.items.map { ConsentItem(purpose: try Bridge.value($0.purpose), granted: $0.granted) })
    }
}
