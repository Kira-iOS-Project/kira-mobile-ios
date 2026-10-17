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
    /** SKR-07, SKR-07b: Riwayat Kira Score. */
    case scoreHistory
    /** The health check again, from the score ("Cek Ulang"). */
    case healthCheck
    /**
     Beranda's and the score's way into paying off: Rencanaku (SKR-04) when the person has a plan,
     else Rencana Pelunasan (SKR-03).
     */
    case debtPlan
    /**
     SKR-03: Rencana Pelunasan, with its open formula (SKR-03b) and the Avalanche method (SKR-03c),
     always: Naskah Negosiasi's "Lihat Simulasi" and Rencanaku's "Ubah Rencana".
     */
    case payoffSimulation
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
    /** REN-01: Rencana, the Rencana tab's root. */
    case plan
    /** REN-02: Tujuan Baru, the goal kinds. */
    case newGoal
    /** REN-02b to REN-02h: the form of one goal kind, chosen in Tujuan Baru. */
    case goalForm(GoalKind)
    /** REN-05: one goal's detail. */
    case goal(id: String)
    /** REN-03 and the other goals' forms, opened from Detail Tujuan's "Ubah Tujuan" on that goal's values. */
    case editGoal(id: String)
    /** REN-06: Kenali Profil Risikomu, the risk-profile quiz. */
    case riskQuiz
    /** REN-09: Cek Legalitas Entitas. */
    case legalityCheck
    /** REN-10: Portofolio Manual. */
    case portfolio
    /** REN-11: Tambah Aset. */
    case addAsset
    /** REN-11 on an asset Portofolio lists: the form updating it. */
    case editAsset(id: String)

    /** REN-07: Hasil Risiko */
    case riskResult
    /** REN-08: Modul Kelas Aset; its screen belongs to work/r4b-modules */
    case assetModule(RiskAssetClass)

    /** UNG-01: Dompet, the wallets and debt accounts. */
    case wallets
    /** UNG-03: Detail Utang of one debt account. */
    case debtDetail(id: String)
    /** SKR-06: Panduan SLIK, reading the credit report. */
    case creditReport
    /** UNG-04: Budget of the current pay period. */
    case budget
    /** UNG-05: Atur Budget. */
    case editBudget
    /** UNG-06: Tagihan & Cicilan. */
    case bills
    /** UNG-07: Tambah Tagihan. */
    case addBill
    /** UNG-07c: Ubah Tagihan of one bill. */
    case editBill(id: String)
    /** UNG-08: Ringkasan Mingguan. */
    case weeklySummary

    /** A link the boards show to an area not built yet: it stays visible and opens nothing. */
    case unavailable(UnavailableArea)
}

/** The areas the boards link to that are not built yet (UNG, REN, KOM and the rest of SKR and PED). */
package enum UnavailableArea: String, CaseIterable, Hashable, Sendable {
    /** UNG-05: Atur Budget, where the payday is set (Beranda's Langkah Awal), until its screen lands. */
    case editBudget
    /** UNG: Ringkasan Mingguan, the weekly summary. */
    case weeklySummary
    /** SKR: SLIK, the credit report. */
    case creditReport
    /** SKR: Detail Utang, one debt account's detail (Rencanaku's account rows). */
    case debtDetail
}
