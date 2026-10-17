/**
 Ubah Tujuan (`AppRoute.editGoal`, from Detail Tujuan): loads the goal, then opens its kind's
 calculator on the saved figures (`GoalFormRoute(editing:)`); "Simpan Perubahan" changes the goal
 and goes back to Detail Tujuan, which loads it again. A goal that cannot be read shows the
 problem with Coba Lagi; one that is gone goes back.
 */
import Domain
import Features
import SwiftUI

struct EditGoalRoute: View {
    @State private var model: GoalDetailModel
    private let service: any GoalService
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(id: String, service: any GoalService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: GoalDetailModel(id: id, service: service))
        self.service = service
        self.onOpen = onOpen
    }

    var body: some View {
        Group {
            switch model.phase {
            case .loaded(let goal): GoalFormRoute(editing: goal, service: service, onOpen: onOpen)
            case .loading:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel(Text("plan.loading"))
            case .empty: GoalGone { dismiss() }
            case .failed(let problem):
                VStack {
                    KiraNavBar("plan.detail.edit", leading: .back("plan.detail.back") { dismiss() })
                    LoadFailedView(title: "plan.detail.failed", problem: problem) { Task { await model.load() } }
                    Spacer()
                }
                .padding(.horizontal, KiraSpacing.screen)
            }
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        /** Once: coming back from Hasil Simulasi keeps the form as it was left. */
        .task { if model.phase.value == nil { await model.load() } }
    }
}
