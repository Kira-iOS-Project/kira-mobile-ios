/**
 The screen of each pushed route, by area: Score (score, indicator, scoreHistory, debtPlan,
 payoffSimulation, myPlan), Account (profile … deleteAccount, about … complaints), Plans (plans …
 scholarshipStatus), Kira Peduli (care, trustedMessage, negotiationScript, breathingExercise,
 safetyPlan), Mode Darurat Utang and its guides (debtEmergency, debtGuide), Etalase (marketplace,
 product, submitProduct), Rencana's Detail Tujuan (goal), Portofolio Manual (portfolio, addAsset,
 editAsset), Tagihan & Cicilan with Tambah and Ubah Tagihan (bills, addBill, editBill);
 the other REN screens stay empty until their branches land. "Cek Ulang" (`healthCheck`)
 covers the shell instead (MainShell); Rencana (`plan`) and Komunitas (`community`) are the dock's own
 sections; Catat's and Riwayat's routes stay empty for their own integration, and an unavailable area
 never gets here.
 */
import Domain
import Features
import SwiftUI

struct RouteSlot: View {
    let route: AppRoute
    let onOpen: (AppRoute) -> Void
    @Environment(\.appServices) private var services
    @Environment(\.endSession) private var endSession

    var body: some View {
        switch route {
        case .score: ScoreScreen(service: services.score, onOpen: onOpen)
        case .indicator(let key): IndicatorScreen(key: key, service: services.score, onOpen: onOpen)
        case .scoreHistory: ScoreHistoryScreen(service: services.score, onOpen: onOpen)
        case .debtPlan:
            PayoffEntryScreen(service: services.payoff, plans: services.payoffPlan, onOpen: onOpen)
        case .payoffSimulation: PayoffScreen(service: services.payoff, plans: services.payoffPlan, onOpen: onOpen)
        case .myPlan: PayoffPlanScreen(service: services.payoffPlan, onOpen: onOpen)
        case .profile:
            ProfileScreen(
                service: services.account, settings: services.security, onOpen: onOpen, onSignedOut: { endSession() })
        case .security, .changePin:
            SecurityScreen(service: services.account, settings: services.security, onOpen: onOpen)
        case .privacy, .deleteAccount:
            PrivacyScreen(
                service: services.account, settings: services.security, onOpen: onOpen, onSignedOut: { endSession() })
        case .about, .terms, .privacyPolicy, .complaints: LegalScreen(route: route, onOpen: onOpen)
        case .plans, .planDetail, .checkout, .subscription, .paymentMethod, .invoices, .treat, .scholarship,
            .scholarshipApply, .scholarshipStatus:
            PlansRoute(route: route, service: services.plans, onOpen: onOpen)
        case .communityGroup(let id): GroupDetailScreen(groupID: id, service: services.community, onOpen: onOpen)
        case .care: CareScreen(service: services.care, onOpen: onOpen)
        case .trustedMessage: TrustedMessageScreen(service: services.care)
        case .debtEmergency:
            DebtEmergencyScreen(care: services.care, service: services.debtEmergency, onOpen: onOpen)
        case .debtGuide(let guide): DebtGuideScreen(guide: guide, care: services.care, onOpen: onOpen)
        case .negotiationScript: NegotiationScriptScreen(service: services.careTools, onOpen: onOpen)
        case .breathingExercise: BreathingScreen()
        case .safetyPlan: SafetyPlanScreen(service: services.careTools)
        case .marketplace: MarketplaceScreen(service: services.marketplace, onOpen: onOpen)
        case .product(let id): ProductScreen(id: id, service: services.marketplace, onOpen: onOpen)
        case .submitProduct: SubmitProductScreen(onOpen: onOpen)
        case .portfolio: PortfolioScreen(service: services.portfolio, onOpen: onOpen)
        case .addAsset: AssetFormScreen(service: services.portfolio, onOpen: onOpen)
        case .editAsset(let id): AssetFormScreen(service: services.portfolio, assetId: id, onOpen: onOpen)
        case .goal(let id): GoalDetailScreen(id: id, service: services.goals, onOpen: onOpen)
        case .newGoal: NewGoalScreen(onOpen: onOpen)
        case .goalForm(let kind): GoalFormRoute(kind: kind, service: services.goals, onOpen: onOpen)
        case .editGoal: EmptySlot()
        case .riskQuiz, .riskResult: riskQuiz(start: route == .riskResult ? .savedResult : .quiz())
        case .legalityCheck: LegalityCheckScreen(onOpen: onOpen)
        case .assetModule(let assetClass): AssetModuleScreen(assetClass: assetClass, onOpen: onOpen)
        case .wallets:
            WalletsScreen(
                service: services.wallet, onOpenDebt: { onOpen(.debtDetail(id: $0)) }, onOpenHelp: { onOpen(.care) })
        case .budget: BudgetScreen(service: services.budget, onOpen: onOpen)
        case .debtDetail: EmptySlot()
        case .creditReport: EmptySlot()
        case .editBudget: EmptySlot()
        case .bills:
            BillsScreen(
                service: services.bills, onAdd: { onOpen(.addBill) }, onEdit: { onOpen(.editBill(id: $0.id)) },
                onOpenDebt: { onOpen(.debtDetail(id: $0)) }, onHelp: { onOpen(.care) })
        case .addBill: AddBillScreen(editor: services.billEditor, wallets: services.wallet, onOpen: onOpen)
        case .editBill(let id):
            EditBillRoute(
                id: id, bills: services.bills, editor: services.billEditor, wallets: services.wallet, onOpen: onOpen)
        case .weeklySummary: WeeklySummaryScreen(service: services.weeklySummary, onOpen: onOpen)
        case .home, .record, .plan, .community, .healthCheck, .recordManual, .receiptScan, .voiceInput, .history,
            .transaction, .conversation, .importStatement, .unavailable:
            EmptySlot()
        }
    }

    /** Kenali Profil Risikomu or Hasil Kuis; without the plan's service the quiz shows no ladder notice. */
    private func riskQuiz(start: RiskQuizModel.Start) -> some View {
        RiskQuizScreen(
            model: RiskQuizModel(
                service: services.riskProfile, draft: services.riskDraft, plans: services.goals, start: start),
            onOpen: onOpen)
    }
}
