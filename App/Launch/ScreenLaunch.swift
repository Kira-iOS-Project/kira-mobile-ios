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
            case .careTools: CareToolsLaunch(screen: screen)
            case .payoffPlan: PayoffPlanLaunch(screen: screen)
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
         SKR: Rencanaku (also before a plan and with a failing payment) and Perayaan Lunas (also after
         the last account).
         */
        case myPlan, myPlanEmpty, myPlanFailing, payoffCelebration, payoffCelebrationLast

        /** The area whose launcher builds the screen. */
        enum Area {
            case onboarding, home, account, plans, record, chat, community, care, careTools, debtEmergency, marketplace
            case payoffPlan
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
            case .marketplace, .marketplaceEmpty, .marketplaceFailed, .product, .productConsultation, .productEbook,
                .productEvent, .productGone, .submitProduct:
                .marketplace
            case .myPlan, .myPlanEmpty, .myPlanFailing, .payoffCelebration, .payoffCelebrationLast: .payoffPlan
            }
        }
    }
#endif
