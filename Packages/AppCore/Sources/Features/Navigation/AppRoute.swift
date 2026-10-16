import Domain

/**
 Every destination a screen can open, pushed on the current tab's navigation stack. Screens never
 build their destinations: they call `onOpen(AppRoute)` and the root decides what to show.
 */
package enum AppRoute: Hashable, Sendable {
    /** BRD: the home tab. */
    case home
    /** SKR: the Kira Score. */
    case score
    /** SKR: one indicator's detail. */
    case indicator(IndicatorKey)
    /** The health check again, from the score ("Cek Ulang"). */
    case healthCheck

    /** CAT: recording by chat. */
    case record
    /** CAT: Catat Manual. */
    case recordManual
    /** CAT: Scan Struk. */
    case receiptScan
    /** CAT: Input Suara. */
    case voiceInput
    /** CAT: Riwayat Transaksi. */
    case history
    /** CAT: Detail Transaksi of one transaction. */
    case transaction(id: String)
    /** CAT: Riwayat Percakapan around one message. */
    case conversation(messageId: String)
    /** CAT: Impor Mutasi. */
    case importStatement

    /** AKN: Profil. */
    case profile
    /** AKN: Keamanan. */
    case security
    /** AKN: changing the app-lock PIN. */
    case changePin
    /** AKN: Data dan Privasi. */
    case privacy
    /** AKN: Hapus Akun. */
    case deleteAccount

    /** AKN: Paket, opened on the yearly prices or the monthly ones. */
    case plans(yearly: Bool)
    /** AKN: one plan's detail. */
    case planDetail(PlanID)
    /** AKN: paying for a plan, monthly or yearly. */
    case checkout(PlanID, yearly: Bool)
    /** AKN: Kelola Langganan. */
    case subscription
    /** AKN: Metode Pembayaran. */
    case paymentMethod
    /** AKN: Riwayat Tagihan. */
    case invoices
    /** AKN: Traktir Kira. */
    case treat

    /** AKN: Beasiswa Kira. */
    case scholarship
    /** AKN: the Beasiswa Kira form. */
    case scholarshipApply
    /** AKN: the Beasiswa Kira application's status. */
    case scholarshipStatus

    /** AKN: Tentang Kira. */
    case about
    /** AKN: Syarat dan Ketentuan. */
    case terms
    /** AKN: Kebijakan Privasi. */
    case privacyPolicy
    /** AKN: Layanan Pengaduan. */
    case complaints

    /** A link the boards show to an area not built yet: it stays visible and opens nothing. */
    case unavailable(UnavailableArea)
}

/** The areas the boards link to that are not built yet (PED, UNG, REN, KOM and the rest of SKR). */
package enum UnavailableArea: String, CaseIterable, Hashable, Sendable {
    /** PED: Kira Peduli. */
    case care
    /** UNG: the budget. */
    case budget
    /** UNG: wallets. */
    case wallets
    /** UNG: bills. */
    case bills
    /** UNG: the weekly summary. */
    case weeklySummary
    /** SKR: the payoff plan. */
    case debtPlan
    /** SKR: the score history. */
    case scoreHistory
    /** SKR: SLIK, the credit report. */
    case creditReport
    /** SKR: the debt emergency mode. */
    case debtEmergency
    /** REN: the Rencana tab. */
    case plan
    /** KOM: the Komunitas tab. */
    case community
}
