import Foundation

/**
 The signed-in person's account, the part of `GET /me` the Akun screens read: who they are, their
 plan and its AI quota, the pay period and the counts behind the Profil rows.
 */
package struct AccountProfile: Equatable, Sendable {
    /** The account's id. */
    package let id: String
    /** The address the person signs in with and receives email at. */
    package let email: String
    /** The first letters of the email's local part, never asked ("dinda@…" is Dinda). */
    package let displayName: String
    /** The plan in force. */
    package let plan: AccountPlan
    /** This period's AI quota. */
    package let usage: AccountUsage
    /** The current pay period. */
    package let period: PayPeriod
    /** How many debt accounts the person keeps. */
    package let debtAccountCount: Int
    /** Sembunyikan Saldo saat Membuka: amounts start masked. */
    package let hidesBalances: Bool
    /** The Kira AI consent is on. */
    package let aiEnabled: Bool
    /** The Ringkasan Mingguan consent is on. */
    package let weeklySummaryEnabled: Bool

    /** An account with every value given. */
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
        /** Bought (a simulation). */
        case purchase
        /** Granted by Beasiswa Kira. */
        case scholarship
    }

    /** Kira Gratis, Muda or Plus. */
    package let id: PlanID
    /** How it was obtained; nil on Kira Gratis. */
    package let source: Source?
    /** The day it renews; nil on Kira Gratis. */
    package let renewsOn: Date?

    /** A plan, Kira Gratis unless told otherwise. */
    package init(id: PlanID, source: Source? = nil, renewsOn: Date? = nil) {
        self.id = id
        self.source = source
        self.renewsOn = renewsOn
    }
}

/** The pay period a budget and a summary cover: from one payday to the day before the next. */
package struct PayPeriod: Equatable, Sendable {
    /** The payday the period starts on. */
    package let start: Date
    /** The day before the next payday. */
    package let end: Date

    /** A period from `start` to `end`, both included. */
    package init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
}
