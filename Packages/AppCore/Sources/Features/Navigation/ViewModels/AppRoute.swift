import Domain

/**
 Every destination a screen can open, pushed on the current tab's navigation stack. Screens never
 build their destinations: they call `onOpen(AppRoute)` and the root decides what to show.
 */
package enum AppRoute: Hashable, Sendable {
    /** BRD-01: Beranda, the home tab's root. */
    case home
    /** SKR-01: Kira Score. */
    case score
    /** SKR-02: one indicator's detail. */
    case indicator(IndicatorKey)
    /** The health check again, from the score ("Cek Ulang"). */
    case healthCheck
    /** SKR-03: Rencana Pelunasan, with its open formula (SKR-03b) and the Avalanche method (SKR-03c). */
    case debtPlan
    /** SKR-04: Rencanaku, the plan the person made; SKR-05 (Perayaan Lunas) opens over it. */
    case myPlan

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

    /** PED-11: Latihan Menenangkan Diri. */
    case breathingExercise
    /** PED-01: Kira Peduli. */
    case care
    /** PED-07: Mode Darurat Utang. */
    case debtEmergency
    /** PED-08, PED-13, PED-14, PED-15: one of Mode Darurat Utang's guides. */
    case debtGuide(DebtGuide)
    /** PED-09: Naskah Pengajuan Keringanan. */
    case negotiationScript
    /** PED-10: Rencana Keselamatanku. */
    case safetyPlan
    /** PED-04: Kirim Pesan ke Layanan Kira. */
    case trustedMessage
    /** KOM-01: Komunitas, the Komunitas tab's root. */
    case community
    /** KOM-02: one community group's detail. */
    case communityGroup(id: String)
    /** KOM-06: Etalase, the curated sellers' products. */
    case marketplace
    /** KOM-07, KOM-07b to KOM-07d: one product's detail, by its kind. */
    case product(id: String)
    /** KOM-08: Kirim Produk ke Etalase. */
    case submitProduct

    /** A link the boards show to an area not built yet: it stays visible and opens nothing. */
    case unavailable(UnavailableArea)
}

/** The areas the boards link to that are not built yet (UNG, REN, KOM and the rest of SKR and PED). */
package enum UnavailableArea: String, CaseIterable, Hashable, Sendable {
    /** UNG: the budget. */
    case budget
    /** UNG: Dompet, the wallets. */
    case wallets
    /** UNG: Tagihan, the bills. */
    case bills
    /** UNG: Ringkasan Mingguan, the weekly summary. */
    case weeklySummary
    /** SKR: Riwayat Skor, the score history. */
    case scoreHistory
    /** SKR: SLIK, the credit report. */
    case creditReport
    /** REN: the Rencana tab. */
    case plan
}
