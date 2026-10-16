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
            case .care: CareLaunch(screen: screen)
            case .careTools: CareToolsLaunch(screen: screen)
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
        /** AKN: Profil and the screens it opens. */
        case profile, security, privacy, about, terms, privacyPolicy, complaints
        /** AKN: plans, the subscription and Beasiswa Kira. */
        case plans, plansYearly, planDetail, checkout, subscription, invoices, treat
        case scholarship, scholarshipApply, scholarshipPending, scholarshipAccepted
        /** CAT: Riwayat, Detail Transaksi, Riwayat Percakapan, Impor Mutasi, Tinjau Hasil Impor. */
        case history, transaction, conversation, statementImport, importReview
        /** CAT: Catat; the tests open its sheets from the composer (ChatLaunch says which account each needs). */
        case record, recordDrafts, recordManual, recordScan, recordQuota, recordVoice
        /**
         PED: Kira Peduli (and offline, on the shipped contacts), its sheet over the chat, the message to
         Layanan Kira.
         */
        case care, careOffline, careHelp, trustedMessage

        /** PED: Naskah Pengajuan Keringanan. */
        case negotiationScript

        /** The area whose launcher builds the screen. */
        enum Area {
            case onboarding, home, account, plans, record, chat, care, careTools
        }

        var area: Area {
            switch self {
            case .splash, .intro, .signUp, .signIn, .code, .consent, .focus, .income, .expenses, .debts, .savings,
                .assets, .protection, .result, .pin:
                .onboarding
            case .home, .homeFirstSteps, .homeDebtPlan, .score, .emergencyFund, .savingsRatio, .instalmentRatio,
                .consumerDebt, .debtToAsset, .protectionCover:
                .home
            case .profile, .security, .privacy, .about, .terms, .privacyPolicy, .complaints: .account
            case .plans, .plansYearly, .planDetail, .checkout, .subscription, .invoices, .treat, .scholarship,
                .scholarshipApply, .scholarshipPending, .scholarshipAccepted:
                .plans
            case .history, .transaction, .conversation, .statementImport, .importReview: .record
            case .record, .recordDrafts, .recordManual, .recordScan, .recordQuota, .recordVoice: .chat
            case .care, .careOffline, .careHelp, .trustedMessage: .care
            case .negotiationScript: .careTools
            }
        }
    }
#endif
