import Domain
import Foundation

/** The signed-in person and their consents (AKN-01, AKN-04, ONB-08, ONB-09). */

/** Which Beranda a person starts on (Pilih Fokus). */
package enum Focus: String, CaseIterable, Sendable {
    /** Catat pengeluaran: the overview. */
    case trackSpending = "track_spending"
    /** Keluar dari utang: the debt plan. */
    case debtFree = "debt_free"
}

/** How the current plan was obtained. */
package enum PlanSource: String, CaseIterable, Sendable {
    /** Bought (simulated). */
    case purchase
    /** Granted by Beasiswa Kira. */
    case scholarship
}

/** The plan in force for the person. */
package struct CurrentPlan: Hashable, Sendable {
    /** Gratis, Muda or Plus. */
    package let id: PlanID
    /** How it was obtained; nil on Gratis. */
    package let source: PlanSource?
    /** When it renews (`YYYY-MM-DD`); nil on Gratis. */
    package let renewsOn: String?
}

/** The signed-in person, with what Beranda, Catat and Akun read on launch (`GET /api/me`). */
package struct Profile: Hashable, Sendable {
    /** The account's id. */
    package let id: String
    /** The sign-in address. */
    package let email: String
    /** The name shown ("Dinda"), from the address. */
    package let displayName: String
    /** Pilih Fokus. */
    package let focus: Focus
    /** Tanggal gajian. */
    package let payday: Payday
    /** Amounts show as Rp•••••• when true. */
    package let hideBalances: Bool
    /** Persetujuan Data was given. */
    package let consented: Bool
    /** The health check was answered. */
    package let healthCheckCompleted: Bool
    /** The plan in force. */
    package let plan: CurrentPlan
    /** The AI-backed inputs used this quota period. */
    package let usage: Usage
    /** The payday period today falls in. */
    package let period: PaydayPeriod
    /** The category of the last expense recorded, preselected in Catat Manual. */
    package let lastExpenseCategory: TransactionCategory?
    /** The category of the last income recorded. */
    package let lastIncomeCategory: TransactionCategory?
    /** Debt accounts on file. */
    package let debtAccountCount: Int
    /** The Kira AI consent: chat, receipt and voice parsing are on. */
    package let aiEnabled: Bool
    /** The weekly-summary consent. */
    package let weeklySummaryEnabled: Bool

    init(_ profile: Components.Schemas.Me) throws {
        id = profile.id
        email = profile.email
        displayName = profile.displayName
        focus = try bridged(profile.focus)
        payday = Payday(day: profile.payday.day, endOfMonth: profile.payday.endOfMonth)
        hideBalances = profile.hideBalances
        consented = profile.consented
        healthCheckCompleted = profile.healthCheckCompleted
        plan = CurrentPlan(
            id: try bridged(profile.plan.id), source: try bridged(profile.plan.source), renewsOn: profile.plan.renewsOn)
        usage = Usage(profile.usage)
        period = PaydayPeriod(
            start: profile.period.start, end: profile.period.end, nextPayday: profile.period.nextPayday,
            daysUntilPayday: profile.period.daysUntilPayday)
        lastExpenseCategory = try bridged(profile.lastCategories.expense)
        lastIncomeCategory = try bridged(profile.lastCategories.income)
        debtAccountCount = profile.debtAccountCount
        aiEnabled = profile.aiEnabled
        weeklySummaryEnabled = profile.weeklySummaryEnabled
    }
}

/** One setting to change with `updateMe(_:)`. */
package enum MeChange: Hashable, Sendable {
    /** Pilih Fokus. */
    case focus(Focus)
    /** Hide or show amounts. */
    case hideBalances(Bool)
    /** Tanggal gajian. */
    case payday(Payday)
}

/** What a person agreed their data may be used for. */
package enum ConsentPurpose: String, CaseIterable, Sendable {
    /** Running the app; always granted. */
    case core
    /** Kira AI parsing chat, receipts and voice on the device. */
    case aiProcessing = "ai_processing"
    /** The weekly summary. */
    case weeklySummary = "weekly_summary"
}

/** One consent decision in force. */
package struct Consent: Hashable, Sendable {
    /** What it is for. */
    package let purpose: ConsentPurpose
    /** Granted or refused. */
    package let granted: Bool
    /** When it was decided; nil when never decided. */
    package let decidedAt: Date?
}

/** The consents in force, under the privacy policy they were given for. */
package struct Consents: Hashable, Sendable {
    /** The privacy policy's version ("2026-10-15"). */
    package let policyVersion: String
    /** One decision per purpose. */
    package let items: [Consent]

    init(_ body: Components.Schemas.Consents) throws {
        policyVersion = body.policyVersion
        items = try body.items.map {
            Consent(purpose: try bridged($0.purpose), granted: $0.granted, decidedAt: $0.decidedAt)
        }
    }
}
