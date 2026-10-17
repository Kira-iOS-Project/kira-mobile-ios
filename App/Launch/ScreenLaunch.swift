/**
 The debug-only screen launcher: a debug build launched with `-KiraScreen <name>` opens that one
 screen on the preview services instead of the app, so the accessibility audit UI tests
 (AGENTS.md Rule 24) reach every primary screen without walking the flows. Release builds compile
 none of it. It stands apart from RootView and its slots, so the shell can change freely.
 */
#if DEBUG
    import SwiftUI

    struct ScreenLaunch: View {
        private let screen: LaunchScreen

        /** The launcher when the arguments hold `-KiraScreen` and a known name after it, else nil. */
        init?(arguments: [String]) {
            guard let index = arguments.firstIndex(of: "-KiraScreen"),
                let name = arguments.dropFirst(index + 1).first,
                let screen = LaunchScreen(rawValue: name)
            else { return nil }
            self.screen = screen
        }

        var body: some View {
            switch screen.area {
            case .onboarding: OnboardingLaunch(screen: screen)
            case .home: HomeLaunch(screen: screen)
            case .account: AccountLaunch(screen: screen)
            case .plans: PlansLaunch(screen: screen)
            case .record: RecordLaunch(screen: screen)
            case .chat: ChatLaunch(screen: screen)
            case .community: CommunityLaunch(screen: screen)
            case .marketplace: MarketplaceLaunch(screen: screen)
            case .care: CareLaunch(screen: screen)
            case .debtEmergency: DebtEmergencyLaunch(screen: screen)
            case .educationGoal: EducationGoalLaunch(screen: screen)
            case .careTools: CareToolsLaunch(screen: screen)
            case .debtDetail: DebtDetailLaunch(screen: screen)
            case .planRisk: PlanRiskLaunch(screen: screen)
            case .houseGoal: HouseGoalLaunch(screen: screen)
            case .weddingGoal: WeddingGoalLaunch(screen: screen)
            case .goals: GoalsLaunch(screen: screen)
            case .retirementGoal: RetirementGoalLaunch(screen: screen)
            case .plan: PortfolioLaunch(screen: screen)
            case .planHome: PlanHomeLaunch(screen: screen)
            case .scoreHistory: ScoreHistoryLaunch(screen: screen)
            case .payoff: PayoffLaunch(screen: screen)
            case .payoffPlan: PayoffPlanLaunch(screen: screen)
            case .planModule: PlanModuleLaunch(screen: screen)
            case .wallets: WalletsLaunch()
            case .budget: BudgetLaunch()
            case .walletAdd: WalletAddLaunch(screen: screen)
            case .bills: BillsLaunch(screen: screen)
            case .billForm: BillFormLaunch(screen: screen)
            case .weeklySummary: WeeklySummaryLaunch(screen: screen)
            case .budgetEdit: BudgetEditLaunch(screen: screen)
            }
        }
    }

    /** Every screen the launcher opens, by the name the UI tests pass. */
    enum LaunchScreen: String, CaseIterable {
        /** ONB: the splash, the intro, Buat Akun, Masuk, the code, the setup, the six quiz steps, the result. */
        case splash, intro, signUp, signIn, code, consent, focus
        case income, expenses, debts, savings, assets, protection
        case result, pin
        /** BRD and SKR. */
        case home, homeFirstSteps, homeDebtPlan, score
        case emergencyFund, savingsRatio, instalmentRatio, consumerDebt, debtToAsset, protectionCover
        /** SKR-02d: Utang Konsumtif with four platforms, all paid on time (KIR-126). */
        case consumerDebtManyOnTime
        /** AKN: Profil and the screens it opens. */
        case profile, security, privacy, about, terms, privacyPolicy, complaints
        /** AKN: plans, the subscription and Beasiswa Kira. */
        case plans, plansYearly, planDetail, checkout, subscription, invoices, treat
        case scholarship, scholarshipApply, scholarshipPending, scholarshipAccepted
        /** CAT: Riwayat, Detail Transaksi, Riwayat Percakapan, Impor Mutasi, Tinjau Hasil Impor. */
        case history, transaction, conversation, statementImport, importReview
        /** CAT: Catat; the tests open its sheets from the composer (ChatLaunch says which account each needs). */
        case record, recordDrafts, recordManual, recordScan, recordQuota, recordVoice
        /** PED: Catat answering a crisis signal (the tests send one), and greeting a due check-in. */
        case crisisSignal, checkInChat
        /** KOM: Komunitas and Detail Grup; the tests open its sheets and dialogs from Detail Grup. */
        case community, communityGroup, communityRules, communityOutbound, communityLinkUnavailable
        case groupReport, groupReportOther, groupReportSent, groupReportFailed
        /**
         PED: Kira Peduli (and offline, on the shipped contacts), its sheet over the chat, the message to
         Layanan Kira.
         */
        case care, careOffline, careHelp, trustedMessage, trustedMessageNoRecipient
        /** PED: Naskah Pengajuan Keringanan. */
        case negotiationScript
        /** PED: Mode Darurat Utang and its four guides. */
        case debtEmergency, harshCollection, illegalLender, unresolvedComplaint, payoffOffer
        /** KOM: Etalase (also empty and failed), Detail Produk of each kind, a product that is gone, Kirim Produk. */
        case marketplace, marketplaceEmpty, marketplaceFailed, product, productConsultation, productEbook, productEvent
        case productGone, submitProduct
        /**
         PED: Latihan Menenangkan Diri; Rencana Keselamatanku (saved, never saved, a save that fails) and
         its form.
         */
        case breathing, safetyPlan, safetyPlanEmpty, safetyPlanFailing, safetyPlanForm
        /**
         REN: Kenali Profil Risikomu fresh (and with the plan unreadable), each later question, a Lihat
         Hasil that fails once, Hasil Kuis for each profile, and Cek Legalitas.
         */
        case riskQuiz, riskQuizUnreadablePlan, riskDrawdown, riskHorizon, riskExperience, riskDeposit, riskSaveFailing
        case riskResult, riskResultConservative, riskResultAggressive, legalityCheck
        /** REN: Tujuan Baru · Kendaraan, Barang Impian and Lainnya on their boards; Hitung opens each result. */
        case goalVehicle, goalGoods, goalOther
        /** REN: Kalkulator Dana Darurat on the board's persona; Hitung opens Hasil Simulasi. */
        case goalEmergency
        /** REN: Tujuan Baru · Dana Pensiun and its Hasil Simulasi, on the board's persona. */
        case goalRetirement, goalRetirementResult
        /** REN: Portofolio (masked, empty, failed), Tambah Aset (a save that fails), updating an asset. */
        case portfolio, portfolioMasked, portfolioEmpty, portfolioFailed, addAsset, addAssetFailing, editAsset
        /** REN: Rencana (with no goal, failed), Detail Tujuan (gone, with a deposit that fails). */
        case plan, planNoGoals, planFailed, goalDetail, goalGone, goalDepositFailing
        /**
         SKR: Riwayat Kira Score (the tests tap 1 Tahun), under a month of data, before the check, failed,
         and outside Kira Plus.
         */
        case scoreHistory, scoreHistoryShort, scoreHistoryEmpty, scoreHistoryFailed, scoreHistoryLocked
        /** SKR: Rencana Pelunasan (03), with Gimana Ngitungnya? open (03b), on Avalanche (03c). */
        case payoff, payoffHow, payoffAvalanche
        /**
         SKR: Rencanaku (also before a plan and with a failing payment) and Perayaan Lunas (also after
         the last account).
         */
        case myPlan, myPlanEmpty, myPlanFailing, payoffCelebration, payoffCelebrationLast
        /** REN-08: Modul Belajar of each asset class. */
        case moduleMoneyMarketFund, moduleGovernmentBonds, moduleDeposits, moduleGold, moduleStocks, moduleCrypto

        /** REN: Tujuan Baru · DP Rumah, its result (the tests tap Jadikan Pos Budget), and a create that fails. */
        case houseGoal, houseGoalResult, houseGoalBudgetFailing
        /** REN: Tujuan Baru · Menikah, its price sheet (the tests tap Venue / Gedung), and its result. */
        case weddingGoal, weddingGoalResult

        /** REN: Tujuan Baru · Pendidikan Anak, Atur Jenjang, and Hasil Simulasi on the board's Raka. */
        case educationGoal, educationGoalResult, educationGoalStage

        /** UNG: Detail Utang (Paylater A, and a debt that is gone) and SKR: Panduan SLIK. */
        case debtDetail, debtDetailGone, creditReportGuide
        /** UNG: Dompet (UNG-01) and Budget (UNG-04) on the preview services. */
        case wallets, budget
        /** UNG: Tambah Dompet over Dompet, and with a save that fails, for its failure dialog. */
        case walletAdd, walletAddFailing
        /** UNG-06: Tagihan & Cicilan with the board's bills, none, and a load that fails. */
        case bills, billsEmpty, billsFailed
        /** UNG: Tambah Tagihan (empty, filled, failing) and Ubah Tagihan; the tests open their dialogs. */
        case billAdd, billAddSaved, billAddFailing, billEdit
        /** UNG-08: Ringkasan Mingguan, a week without spending, and a week that failed to load. */
        case weeklySummary, weeklySummaryEmpty, weeklySummaryFailed
        /** UNG-05: Atur Budget on its board; the tests save (Budget Tersimpan) or fail (Belum Berhasil Menyimpan). */
        case budgetEdit, budgetEditFailing

        /** The area whose launcher builds the screen. */
        enum Area {
            case onboarding, home, account, plans, record, chat, community, care, careTools, debtEmergency, marketplace
            case debtDetail
            case planRisk
            case houseGoal, weddingGoal, educationGoal
            case goals
            case retirementGoal
            case plan, planHome
            case scoreHistory
            case payoff
            case payoffPlan
            case planModule
            case wallets, budget
            case walletAdd
            case bills
            case billForm
            case weeklySummary
            case budgetEdit
        }

        var area: Area {
            switch self {
            case .splash, .intro, .signUp, .signIn, .code, .consent, .focus, .income, .expenses, .debts, .savings,
                .assets, .protection, .result, .pin:
                .onboarding
            case .home, .homeFirstSteps, .homeDebtPlan, .score, .emergencyFund, .savingsRatio, .instalmentRatio,
                .consumerDebt, .consumerDebtManyOnTime, .debtToAsset, .protectionCover:
                .home
            case .profile, .security, .privacy, .about, .terms, .privacyPolicy, .complaints: .account
            case .plans, .plansYearly, .planDetail, .checkout, .subscription, .invoices, .treat, .scholarship,
                .scholarshipApply, .scholarshipPending, .scholarshipAccepted:
                .plans
            case .history, .transaction, .conversation, .statementImport, .importReview: .record
            case .record, .recordDrafts, .recordManual, .recordScan, .recordQuota, .recordVoice, .crisisSignal,
                .checkInChat:
                .chat
            case .community, .communityGroup, .communityRules, .communityOutbound, .communityLinkUnavailable,
                .groupReport, .groupReportOther, .groupReportSent, .groupReportFailed:
                .community
            case .care, .careOffline, .careHelp, .trustedMessage, .trustedMessageNoRecipient: .care
            case .breathing, .negotiationScript, .safetyPlan, .safetyPlanEmpty, .safetyPlanFailing, .safetyPlanForm:
                .careTools
            case .debtEmergency, .harshCollection, .illegalLender, .unresolvedComplaint, .payoffOffer: .debtEmergency
            case .payoff, .payoffHow, .payoffAvalanche: .payoff
            case .educationGoal, .educationGoalResult, .educationGoalStage: .educationGoal
            case .bills, .billsEmpty, .billsFailed: .bills
            case .budgetEdit, .budgetEditFailing: .budgetEdit
            case .marketplace, .marketplaceEmpty, .marketplaceFailed, .product, .productConsultation, .productEbook,
                .productEvent, .productGone, .submitProduct:
                .marketplace
            case .riskQuiz, .riskQuizUnreadablePlan, .riskDrawdown, .riskHorizon, .riskExperience, .riskDeposit,
                .riskSaveFailing, .riskResult, .riskResultConservative, .riskResultAggressive, .legalityCheck:
                .planRisk
            case .houseGoal, .houseGoalResult, .houseGoalBudgetFailing: .houseGoal
            case .weddingGoal, .weddingGoalResult: .weddingGoal
            case .goalVehicle, .goalGoods, .goalOther, .goalEmergency: .goals
            case .goalRetirement, .goalRetirementResult: .retirementGoal
            case .portfolio, .portfolioMasked, .portfolioEmpty, .portfolioFailed, .addAsset, .addAssetFailing,
                .editAsset:
                .plan
            case .plan, .planNoGoals, .planFailed, .goalDetail, .goalGone, .goalDepositFailing: .planHome
            case .scoreHistory, .scoreHistoryShort, .scoreHistoryEmpty, .scoreHistoryFailed, .scoreHistoryLocked:
                .scoreHistory
            case .myPlan, .myPlanEmpty, .myPlanFailing, .payoffCelebration, .payoffCelebrationLast: .payoffPlan
            case .moduleMoneyMarketFund, .moduleGovernmentBonds, .moduleDeposits, .moduleGold, .moduleStocks,
                .moduleCrypto:
                .planModule
            case .debtDetail, .debtDetailGone, .creditReportGuide: .debtDetail
            case .wallets: .wallets
            case .budget: .budget
            case .walletAdd, .walletAddFailing: .walletAdd
            case .billAdd, .billAddSaved, .billAddFailing, .billEdit: .billForm
            case .weeklySummary, .weeklySummaryEmpty, .weeklySummaryFailed: .weeklySummary
            }
        }
    }
#endif
