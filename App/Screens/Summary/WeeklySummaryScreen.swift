import Domain
import Features
import SwiftUI

/** UNG-08: completed Thursday-to-Wednesday totals and spending overview. */
struct WeeklySummaryScreen: View {
    @State private var model: WeeklySummaryModel
    private let onOpenHistory: () -> Void
    @Environment(\.dismiss) private var dismiss

    init(service: any WeeklySummaryService, onOpenHistory: @escaping () -> Void) {
        _model = State(initialValue: WeeklySummaryModel(service: service))
        self.onOpenHistory = onOpenHistory
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("weekly.title", leading: .back("weekly.back") { dismiss() }) {
                    KiraHelpButton(.icon) {}
                }
                switch model.phase {
                case .loading: WeeklyLoadingView()
                case .empty: WeeklyEmptyView()
                case .loaded(let summary):
                    WeeklySummaryContent(summary: summary, model: model, onOpenHistory: onOpenHistory)
                case .failed(let problem):
                    LoadFailedView(title: "weekly.failed", problem: problem) { Task { await model.load() } }
                }
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.space10)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 48, y: -20)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }
}
