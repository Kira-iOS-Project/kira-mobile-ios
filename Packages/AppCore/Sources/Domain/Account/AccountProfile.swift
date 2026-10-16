import Foundation

/**
 The signed-in person's account, the part of `GET /me` the Akun screens read: who they are, their
 plan and its AI quota, the pay period and the counts behind the Profil rows.
 */
package struct AccountProfile: Equatable, Sendable {
    package let id: String
    package let email: String
    /** The first letters of the email's local part, never asked ("dinda@…" is Dinda). */
    package let displayName: String
    package let plan: AccountPlan
    package let usage: AccountUsage
    package let period: PayPeriod
    package let debtAccountCount: Int
    package let hidesBalances: Bool
    package let aiEnabled: Bool
    package let weeklySummaryEnabled: Bool

    package init(
        id: String, email: String, displayName: String, plan: AccountPlan, usage: AccountUsage, period: PayPeriod,
        debtAccountCount: Int, hidesBalances: Bool, aiEnabled: Bool, weeklySummaryEnabled: Bool
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.plan = plan
        self.usage = usage
        self.period = period
        self.debtAccountCount = debtAccountCount
        self.hidesBalances = hidesBalances
        self.aiEnabled = aiEnabled
        self.weeklySummaryEnabled = weeklySummaryEnabled
    }

    /** The avatar's letter: the name's first, else the email's, in capitals. */
    package var initial: String {
        let source = displayName.isEmpty ? email : displayName
        return source.first.map { String($0).uppercased() } ?? ""
    }
}

/** The plan in force: which one, how it was obtained and when it renews. */
package struct AccountPlan: Equatable, Sendable {
    /** How the plan was obtained: the backend's `PLAN_SOURCE` values. */
    package enum Source: String, Codable, Sendable {
        case purchase
        case scholarship
    }

    package let id: PlanID
    package let source: Source?
    package let renewsOn: Date?

    package init(id: PlanID, source: Source? = nil, renewsOn: Date? = nil) {
        self.id = id
        self.source = source
        self.renewsOn = renewsOn
    }
}

/** The pay period a budget and a summary cover: from one payday to the day before the next. */
package struct PayPeriod: Equatable, Sendable {
    package let start: Date
    package let end: Date

    package init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
}
