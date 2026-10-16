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
    package let usage: Usage
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
        id: String, email: String, displayName: String, plan: AccountPlan, usage: Usage, period: PayPeriod,
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

/** The plan in force. */
package struct AccountPlan: Equatable, Sendable {
    /** Kira Gratis, Muda or Plus. */
    package let id: PlanID

    /** The plan `id`. */
    package init(id: PlanID) {
        self.id = id
    }
}
