/**
 The way into paying off from Beranda and the score: Rencanaku (SKR-04) when the person has a
 plan, else Rencana Pelunasan (SKR-03), once the plan has been asked for.
 */
import Domain
import Features
import SwiftUI

struct PayoffEntryScreen: View {
    @State private var model: PayoffEntryModel
    private let service: any PayoffService
    private let plans: any PayoffPlanService
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(service: any PayoffService, plans: any PayoffPlanService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: PayoffEntryModel(plans: plans))
        self.service = service
        self.plans = plans
        self.onOpen = onOpen
    }

    var body: some View {
        Group {
            switch model.phase {
            case .loading:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel(Text("payoff.loading"))
            case .loaded: PayoffPlanScreen(service: plans, onOpen: onOpen)
            case .empty: PayoffScreen(service: service, plans: plans, onOpen: onOpen)
            case .failed(let problem):
                LoadFailedView(title: "payoff.failed", leading: .back("payoff.back") { dismiss() }, problem: problem) {
                    Task { await model.load() }
                }
            }
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }
}
