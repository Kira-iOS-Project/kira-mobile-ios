/**
 REN-06 to REN-06e, Kenali Profil Risikomu, and REN-07, Hasil Kuis, as one screen: the question on
 screen or the server's profile, from `RiskQuizModel`. Closing the quiz, or Kembali on the first
 question, leaves it with the answers kept for the session ("Tutup kuis, jawaban tersimpan"); Hasil
 Kuis's back leaves it too, so it returns to Rencana. A failed Lihat Hasil shows the failure dialog.
 */
import Domain
import Features
import SwiftUI

struct RiskQuizScreen: View {
    @State private var model: RiskQuizModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(model: RiskQuizModel, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: model)
        self.onOpen = onOpen
    }

    var body: some View {
        content
            .task { await model.load() }
            .riskSaveFailureDialog(failure: $model.failure) { Task { await model.retry() } }
            .onChange(of: model.isClosed) { _, closed in
                if closed { dismiss() }
            }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading, .empty:
            PlanScreenFrame {
                ProgressView().frame(maxWidth: .infinity).padding(.vertical, KiraSpacing.space8)
            }
        case .failed(let problem):
            PlanScreenFrame {
                LoadFailedView(problem: problem) { Task { await model.load() } }
            }
        case .loaded(let context):
            switch model.stage {
            case .question(let question):
                RiskQuestionView(question: question, context: context, model: model, onOpen: onOpen) { dismiss() }
            case .result(let profile):
                RiskResultView(profile: profile, onOpen: onOpen, onRestart: model.restart) { dismiss() }
            }
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            RiskQuizScreen(
                model: RiskQuizModel(
                    service: PreviewRiskProfileService(), draft: RiskQuizDraft(), plans: PreviewGoalService()),
                onOpen: { _ in })
        }
    }
#endif
