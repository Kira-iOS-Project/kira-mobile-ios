/**
 Rencana Pelunasan (SKR-03; the formula open is SKR-03b, the Avalanche method SKR-03c), as the
 RencanaPelunasan boards lay it: the method and the extra payment, what the plan comes to, the
 order of the accounts, the other method, "Hanya Simulasi", "Gimana Ngitungnya?", then "Nanti Saja"
 and "Jadikan Rencanaku". Changing the method or the extra payment asks the API again and the same
 page answers. Pushed from Beranda, the score's steps and Naskah Negosiasi's "Lihat Simulasi".
 */
import APIClient
import Domain
import Features
import SwiftUI

struct PayoffScreen: View {
    @State private var model: PayoffModel
    private let plans: any PayoffPlanService
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(service: any PayoffService, plans: any PayoffPlanService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: PayoffModel(service: service))
        self.plans = plans
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("payoff.title", subtitle: subtitle, leading: .back("payoff.back") { dismiss() }) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space1)
            .padding(.bottom, KiraSpacing.space10)
        }
        .background(alignment: .topTrailing) {
            KiraLeaf(.twig, tone: .soft, size: 130, isFlipped: true).offset(x: 38, y: 34).ignoresSafeArea()
                .accessibilityHidden(true)
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }

    /** "3 akun utang": the consumer accounts and the debts the plan leaves alone. */
    private var subtitle: LocalizedStringResource? {
        model.phase.value.map { "payoff.accounts \($0.accounts.count + $0.productive.count)" }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity, minHeight: 240)
                .accessibilityLabel(Text("payoff.loading"))
        case .empty:
            PayoffEmptyView()
        case .failed(let problem):
            LoadFailedView(title: "payoff.failed", problem: problem) { Task { await model.load() } }
        case .loaded(let simulation):
            PayoffLoaded(model: model, simulation: simulation, onLater: { dismiss() }, onMakePlan: makePlan)
        }
    }

    /** Saves the plan on screen as Rencanaku and opens it. */
    private func makePlan() {
        Task { if await model.makePlan(using: plans) { onOpen(.myPlan) } }
    }
}

/** The loaded plan, top to bottom as the board lays it. */
private struct PayoffLoaded: View {
    let model: PayoffModel
    let simulation: PayoffSimulation
    let onLater: () -> Void
    let onMakePlan: () -> Void

    var body: some View {
        PayoffControls(model: model, simulation: simulation)
            .padding(.top, KiraSpacing.space1)
        if let problem = model.recalculationProblem {
            KiraNotice(.warning, title: "payoff.recalc.failed", message: problem.message)
        }
        Group {
            PayoffHero(simulation: simulation)
            PayoffOrderList(simulation: simulation)
            PayoffNotices(simulation: simulation)
        }
        .opacity(model.isRecalculating ? 0.5 : 1)
        PayoffHowAccordion(model: model, simulation: simulation)
        if let problem = model.makePlanProblem {
            KiraNotice(.warning, title: "payoff.makePlan.failed", message: problem.message)
        }
        WeightedRow(weights: [1, 1.3], spacing: KiraSpacing.space2) {
            KiraButton("payoff.later", variant: .secondary, size: .small, action: onLater).block()
            KiraButton("payoff.makePlan", size: .small, action: onMakePlan).block()
                .disabled(simulation.accounts.isEmpty || model.isMakingPlan || model.exceedsMaximum)
        }
        .padding(.top, KiraSpacing.space1)
    }
}

/** Before any consumer debt: nothing to plan. */
private struct PayoffEmptyView: View {
    var body: some View {
        VStack(spacing: KiraSpacing.space3) {
            KiraIllustration(.sprout, size: 128)
            Text("payoff.empty.title").kiraFont(.title).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
            Text("payoff.empty.body").kiraFont(.callout).foregroundStyle(.inkMuted)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, KiraSpacing.space10)
    }
}
