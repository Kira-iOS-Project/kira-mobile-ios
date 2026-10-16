/**
 The screens `ScreenLaunch` opens, area by area, each on its preview service and inside a
 navigation stack as the shell pushes it. Links out go nowhere: the audit reads one screen.
 */
#if DEBUG
    import Domain
    import Features
    import SwiftUI

    /** ONB: the onboarding flow, already pushed to the screen asked for. */
    struct OnboardingLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            if screen == .splash {
                SplashView()
            } else {
                OnboardingFlow(
                    service: PreviewOnboardingService(), pinSetup: PreviewPinSetup(), onFinished: { _ in },
                    start: start)
            }
        }

        private var start: [OnboardingScreen] {
            switch screen {
            case .signUp: [.signUp]
            case .signIn: [.signIn]
            case .code: [.signUp, .code(email: "dinda@email.com", delivery: delivery)]
            case .consent: [.consent]
            case .focus: [.consent, .focus]
            case .income: [.healthCheck(.income)]
            case .expenses: [.healthCheck(.expenses)]
            case .debts: [.healthCheck(.debts)]
            case .savings: [.healthCheck(.savings)]
            case .assets: [.healthCheck(.assets)]
            case .protection: [.healthCheck(.protection)]
            case .result: [.result(PreviewOnboardingService.sampleReport)]
            case .pin: [.pin]
            default: []
            }
        }

        private var delivery: CodeDelivery { CodeDelivery(expiresInSeconds: 600, resendAfterSeconds: 60) }
    }

    /** BRD and SKR: the three Beranda, Kira Score and the six indicators. */
    struct HomeLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                switch screen {
                case .homeFirstSteps: HomeScreen(service: PreviewHomeService(.sampleFirstSteps)) { _ in }
                case .homeDebtPlan: HomeScreen(service: PreviewHomeService(.sampleDebtPlan)) { _ in }
                case .score: ScoreScreen(service: PreviewScoreService()) { _ in }
                case .emergencyFund: indicator(.emergencyFund)
                case .savingsRatio: indicator(.savingsRatio)
                case .instalmentRatio: indicator(.instalmentRatio)
                case .consumerDebt: indicator(.consumerDebt)
                case .debtToAsset: indicator(.debtToAsset)
                case .protectionCover: indicator(.protection)
                default: HomeScreen(service: PreviewHomeService()) { _ in }
                }
            }
        }

        private func indicator(_ key: IndicatorKey) -> some View {
            IndicatorScreen(key: key, service: PreviewScoreService()) { _ in }
        }
    }

    /** AKN: Profil and what it opens, through the area's own preview flow. */
    struct AccountLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            switch screen {
            case .security: AccountPreviewFlow(start: [.security])
            case .privacy: AccountPreviewFlow(start: [.privacy])
            case .about: AccountPreviewFlow(start: [.about])
            case .terms: AccountPreviewFlow(start: [.about, .terms])
            case .privacyPolicy: AccountPreviewFlow(start: [.about, .privacyPolicy])
            case .complaints: AccountPreviewFlow(start: [.about, .complaints])
            default: AccountPreviewFlow()
            }
        }
    }

    /** CAT: Riwayat, a transaction, its conversation, and the statement import with its review. */
    struct RecordLaunch: View {
        let screen: LaunchScreen
        private let service = PreviewHistoryService()

        var body: some View {
            NavigationStack {
                switch screen {
                case .transaction: TransactionDetailScreen(id: "grab", service: service) { _ in }
                case .conversation: ConversationScreen(sourceMessageId: "m-1241", service: service)
                case .statementImport: StatementImportScreen(service: service, onOpen: { _ in }, onFinish: {})
                case .importReview:
                    ImportReviewScreen(
                        preview: Self.review, fileName: "mutasi-oktober.csv", service: service, onOpen: { _ in },
                        onFinish: {})
                default: HistoryScreen(service: service) { _ in }
                }
            }
        }

        /** Four rows of a bank statement, the first one already recorded. */
        private static let review: ImportPreview = {
            let rows = [
                ("Gaji Oktober", 7_500_000, TransactionType.income, TransactionCategory.salary, false),
                ("Indomaret Kemang", 86_500, .expense, .shopping, false),
                ("Grab ke kantor", 18_000, .expense, .transport, true),
                ("PLN Token", 300_000, .expense, .bills, false),
            ]
            let day = CalendarDay(year: 2026, month: 10, day: 14)
            return ImportPreview(
                id: "import-preview", dateFrom: CalendarDay(year: 2026, month: 10, day: 1), dateTo: day,
                rows: rows.enumerated().map { index, row in
                    ImportPreviewRow(
                        id: "row-\(index)", day: day, description: row.0, amount: row.1, type: row.2,
                        category: row.3, isDuplicate: row.4)
                })
        }()
    }
#endif
