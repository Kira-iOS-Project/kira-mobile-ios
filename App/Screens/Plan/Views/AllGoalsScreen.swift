/**
 Semua Tujuan (REN-01b), from Tujuanmu's "Lihat Semua": every goal's card, each opening Detail
 Tujuan, with "Tambah" to Tujuan Baru. It loads Rencana again on each visit, so a goal deleted or
 changed in Detail Tujuan is gone or changed on return.
 */
import Domain
import Features
import SwiftUI

struct AllGoalsScreen: View {
    @State private var model: PlanModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(service: any GoalService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: PlanModel(service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("plan.goals.all.title", leading: .back("plan.goals.all.back") { dismiss() }) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, 62 - 59)
            .padding(.bottom, KiraSpacing.screenBottom)
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
            goalsSection([])
        case .loaded(let plan):
            goalsSection(plan.goals)
        }
    }

    private func goalsSection(_ goals: [GoalSummary]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle(
                "plan.goals.all.count \(goals.count)", trailing: .action("plan.goals.add") { onOpen(.newGoal) })
            if goals.isEmpty {
                Text("plan.goals.empty").kiraFont(.callout).foregroundStyle(.inkMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(KiraSpacing.space4)
                    .kiraCard()
            }
            GoalCards(goals: goals, emergencyMultiple: model.emergencyTargetMultiple, onOpen: onOpen)
        }
    }
}
