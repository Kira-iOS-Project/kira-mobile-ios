/**
 Rencana (REN-01), the Rencana tab's root: the four-step ladder from the engine, Tujuanmu with the
 first five goals' cards (opening Detail Tujuan), "Lihat Semua" to Semua Tujuan once there are more,
 and "Tambah" to Tujuan Baru, and Belajar Investasi with the risk
 quiz, Cek Legalitas and Portofolio Manual. The help button opens Kira Peduli; the dock stays.
 */
import Domain
import Features
import SwiftUI

struct PlanScreen: View {
    @State private var model: PlanModel
    private let onOpen: (AppRoute) -> Void

    init(service: any GoalService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: PlanModel(service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("plan.home.title", isLarge: true) {
                    KiraHelpButton(.pill) { onOpen(.care) }
                }
                .eyebrow("plan.eyebrow")
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space1)
            .padding(.bottom, KiraSpacing.space10 + KiraSpacing.dockReserve)
        }
        .background(alignment: .topTrailing) {
            KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 34, y: 30).ignoresSafeArea()
                .accessibilityHidden(true)
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
        .refreshable { await model.load() }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity, minHeight: 200)
                .accessibilityLabel(Text("plan.loading"))
        case .failed(let problem):
            LoadFailedView(title: "plan.home.failed", problem: problem) { Task { await model.load() } }
        case .empty:
            PlanLearning(onOpen: onOpen)
        case .loaded(let plan):
            PlanLadderCard(ladder: plan.ladder, emergency: model.emergencyGoal)
            PlanGoals(goals: plan.goals, emergencyMultiple: model.emergencyTargetMultiple, onOpen: onOpen)
            PlanLearning(onOpen: onOpen)
        }
    }
}

/** Tujuanmu: "Tambah" opens Tujuan Baru, each card its goal; past five, "Lihat Semua" opens the rest. */
private struct PlanGoals: View {
    /** The most cards Tujuanmu shows. */
    static let shown = 5

    let goals: [GoalSummary]
    /** The emergency fund's target in months of essential spending, from the ladder ("Target 6×"). */
    let emergencyMultiple: Double?
    let onOpen: (AppRoute) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("plan.goals.title", trailing: .action("plan.goals.add") { onOpen(.newGoal) })
            if goals.isEmpty {
                Text("plan.goals.empty").kiraFont(.callout).foregroundStyle(.inkMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(KiraSpacing.space4)
                    .kiraCard()
            }
            GoalCards(goals: Array(goals.prefix(Self.shown)), emergencyMultiple: emergencyMultiple, onOpen: onOpen)
            if goals.count > Self.shown {
                KiraButton("plan.goals.seeAll \(goals.count)", variant: .secondary) { onOpen(.goals) }
                    .iconEnd(.arrowRight).block()
            }
        }
        .padding(.top, KiraSpacing.space2)
    }
}

/** Goal cards, each opening its Detail Tujuan; the emergency fund's names its target ("Target 6×"). */
struct GoalCards: View {
    let goals: [GoalSummary]
    let emergencyMultiple: Double?
    let onOpen: (AppRoute) -> Void

    var body: some View {
        ForEach(goals, id: \.id) { goal in
            PlanGoalCard(goal: goal, targetMultiple: goal.kind == .emergencyFund ? emergencyMultiple : nil) {
                onOpen(.goal(id: goal.id))
            }
        }
    }
}

/** Belajar Investasi: the quiz card, then Cek Legalitas and Portofolio Manual. */
private struct PlanLearning: View {
    let onOpen: (AppRoute) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("plan.learn.title", trailing: .note("plan.learn.note"))
            PlanQuizCard { onOpen(.riskQuiz) }
            KiraListGroup("plan.tools.label", footer: "plan.tools.footer") {
                KiraListRow(Text("plan.legality.title"), leading: .icon(.shield), trailing: .chevron) {
                    onOpen(.legalityCheck)
                }
                .subtitle(Text("plan.legality.subtitle"))
                KiraListRow(Text("plan.portfolio.title"), leading: .icon(.chart), trailing: .chevron) {
                    onOpen(.portfolio)
                }
                .subtitle(Text("plan.portfolio.subtitle"))
            }
        }
        .padding(.top, KiraSpacing.space2)
    }
}
