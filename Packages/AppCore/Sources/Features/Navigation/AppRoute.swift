import Domain

/**
 Every destination a screen can open, pushed on the current tab's navigation stack. Screens never
 build their destinations: they call `onOpen(AppRoute)` and the root decides what to show.
 */
package enum AppRoute: Hashable, Sendable {
    /** BRD-01: Beranda, the home tab's root. */
    case home
    /** UNG-06: recurring bills and debt installments. */
    case bills
    /** SKR-01: Kira Score. */
    case score
    /** SKR-02: one indicator's detail. */
    case indicator(IndicatorKey)
    /** The health check again, from the score ("Cek Ulang"). */
    case healthCheck

    /** CAT-01: Catat, the record section's root. */
    case record
    /** CAT-04: Catat Manual. */
    case recordManual
    /** CAT-05: Scan Struk. */
    case receiptScan
    /** CAT-10: Input Suara. */
    case voiceInput
    /** CAT-07: Riwayat Transaksi. */
    case history
    /** CAT-08: one transaction's detail. */
    case transaction(id: String)
    /** CAT-08f: the conversation around one chat message. */
    case conversation(messageId: String)
    /** CAT-11: Impor Mutasi. */
    case importStatement

    /** AKN-01: Profil. */
    case profile
    /** UNG-01: Dompet & Akun Utang, opened from Profil. */
    case wallets
    /** UNG-03: one debt account's detail, opened from Dompet. */
    case debtDetail(id: String)
    /** AKN-03: Keamanan. */
    case security
    /** AKN-03: Ganti PIN. */
    case changePin
    /** AKN-04: Data & Privasi. */
    case privacy
    /** AKN-05: Hapus Akun dan Data. */
    case deleteAccount

    /** AKN-06: Paket Kira, monthly or yearly prices. */
    case plans(yearly: Bool)
    /** AKN-06g, AKN-06h: one plan's detail. */
    case planDetail(PlanID)
    /** AKN-06b, AKN-06e: the simulated payment for a plan. */
    case checkout(PlanID, yearly: Bool)
    /** AKN-07: Langganan. */
    case subscription
    /** AKN-07d: Metode Pembayaran. */
    case paymentMethod
    /** AKN-07e: Riwayat Tagihan. */
    case invoices
    /** AKN-07f: Traktir Kira. */
    case treat

    /** AKN-09: Beasiswa Kira. */
    case scholarship
    /** AKN-10: Ajukan Beasiswa Kira. */
    case scholarshipApply
    /** AKN-10c, AKN-10d: the application's status. */
    case scholarshipStatus

    /** AKN-08: Tentang Kira. */
    case about
    /** AKN-08b: Syarat dan Ketentuan. */
    case terms
    /** AKN-08c: Kebijakan Privasi. */
    case privacyPolicy
    /** AKN-08d: Layanan Pengaduan. */
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
    /** UNG: Tagihan, the bills. */
    case bills
    /** UNG: Ringkasan Mingguan, the weekly summary. */
    case weeklySummary
    /** SKR: Rencana Pelunasan, the payoff plan. */
    case debtPlan
    /** SKR: Riwayat Skor, the score history. */
    case scoreHistory
    /** SKR: SLIK, the credit report. */
    case creditReport
    /** SKR: Mode Darurat Utang. */
    case debtEmergency
    /** REN: the Rencana tab. */
    case plan
    /** KOM: the Komunitas tab. */
    case community
}
