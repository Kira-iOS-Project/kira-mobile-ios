import Domain

/**
 Every destination a screen can open, pushed on the current tab's navigation stack. Screens never
 build their destinations: they call `onOpen(AppRoute)` and the root decides what to show.
 */
package enum AppRoute: Hashable, Sendable {
    /** BRD and SKR: the home tab, the Kira Score and one indicator's detail. */
    case home
    case score
    case indicator(IndicatorKey)
    /** The health check again, from the score ("Cek Ulang"). */
    case healthCheck

    /** CAT: recording by chat, manual entry, receipt, voice, history and imports. */
    case record
    case recordManual
    case receiptScan
    case voiceInput
    case history
    case transaction(id: String)
    case conversation(messageId: String)
    case importStatement

    /** AKN: profile, security, privacy and the account's end. */
    case profile
    case security
    case changePin
    case privacy
    case deleteAccount

    /** AKN: plans, checkout, the subscription and its payments. */
    case plans(yearly: Bool)
    case planDetail(PlanID)
    case checkout(PlanID, yearly: Bool)
    case subscription
    case paymentMethod
    case invoices
    case treat

    /** AKN: Beasiswa Kira. */
    case scholarship
    case scholarshipApply
    case scholarshipStatus

    /** AKN: about Kira and its documents. */
    case about
    case terms
    case privacyPolicy
    case complaints

    /** A link the boards show to an area not built yet: it stays visible and opens nothing. */
    case unavailable(UnavailableArea)
}

/** The areas the boards link to that are not built yet (PED, UNG, REN, KOM and the rest of SKR). */
package enum UnavailableArea: String, CaseIterable, Hashable, Sendable {
    /** PED: Kira Peduli. */
    case care
    /** UNG: budget, wallets, bills and the weekly summary. */
    case budget
    case wallets
    case bills
    case weeklySummary
    /** SKR: the payoff plan, the score history, SLIK and the debt emergency mode. */
    case debtPlan
    case scoreHistory
    case creditReport
    case debtEmergency
    /** REN and KOM: the Rencana and Komunitas tabs. */
    case plan
    case community
}
