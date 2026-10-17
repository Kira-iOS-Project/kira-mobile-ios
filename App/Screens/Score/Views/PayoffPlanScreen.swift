/**
 Rencanaku (SKR-04): the plan the person made, how far it has come, the payment to make next
 ("Tandai Sudah Bayar") and the accounts with their tags. The payment that settles an account opens
 Perayaan Lunas (SKR-05) over the page, once. Pushed from "Jadikan Rencanaku".
 */
import APIClient
import Domain
import Features
import SwiftUI

struct PayoffPlanScreen: View {
    @State private var model: PayoffPlanModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(service: any PayoffPlanService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: PayoffPlanModel(service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        Group {
            switch model.phase {
            case .loading:
                PayoffPlanContent(model: model, plan: .sample, onOpen: { _ in }, onBack: {})
                    .redacted(reason: .placeholder)
                    .disabled(true)
            case .loaded(let plan):
                PayoffPlanContent(model: model, plan: plan, onOpen: onOpen) { dismiss() }
            case .empty:
                PayoffPlanEmptyView(onOpen: onOpen) { dismiss() }
            case .failed(let problem):
                LoadFailedView(title: "plan.failed", problem: problem) { Task { await model.load() } }
            }
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
        .kiraSheet(isPresented: celebrating, title: "plan.celebrate.sheet") {
            if let payment = model.celebration {
                PayoffCelebration(payment: payment, name: model.celebratedName ?? "") { destination in
                    model.dismissCelebration()
                    if let destination { onOpen(destination) }
                }
            }
        }
    }

    private var celebrating: Binding<Bool> {
        Binding(
            get: { model.celebration != nil },
            set: { if !$0 { model.dismissCelebration() } })
    }
}

/** The loaded plan, top to bottom. */
private struct PayoffPlanContent: View {
    let model: PayoffPlanModel
    let plan: ActivePayoffPlan
    let onOpen: (AppRoute) -> Void
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space5) {
                PayoffPlanHeader(onOpen: onOpen, onBack: onBack)
                KiraProgressRibbon(value: Double(plan.progressPercent), target: 100, label: "plan.progress.label")
                    .caption(PayoffPlanCopy.caption(method: plan.method, extraPayment: plan.extraPayment))
                if let problem = model.actionProblem {
                    KiraNotice(.warning, title: "plan.action.failed", message: problem.message)
                }
                if let next = plan.nextPayment {
                    PayoffNextPaymentCard(payment: next, isWorking: model.isWorking) { Task { await model.markPaid() } }
                } else {
                    PayoffPlanDoneCard { onOpen(.score) }
                }
                PayoffPlanAccounts(model: model, plan: plan)
                if !plan.ongoingAccounts.isEmpty {
                    PayoffOngoingList(accounts: plan.ongoingAccounts)
                }
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, 3)
            .padding(.bottom, KiraSpacing.space10)
        }
        .kiraScrollEdges()
    }
}

/** The back button and Kira Peduli, the title and what the page does. */
private struct PayoffPlanHeader: View {
    let onOpen: (AppRoute) -> Void
    let onBack: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space1) {
            HStack {
                KiraIconButton.back("plan.back", action: onBack)
                Spacer(minLength: KiraSpacing.space2)
                KiraHelpButton { onOpen(.care) }
                    /** At accessibility sizes it wraps rather than widen the page. */
                    .fixedSize(horizontal: !typeSize.isAccessibilitySize, vertical: true)
            }
            .frame(minHeight: KiraSize.tap)
            Text("plan.title").kiraFont(.largeTitle).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
            Text("plan.subtitle")
                .font(.footnote.weight(.medium)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
        }
        .padding(.bottom, KiraSpacing.space3)
    }
}

/** Before a plan is made: what Rencanaku is, and the way to Rencana Pelunasan. */
private struct PayoffPlanEmptyView: View {
    let onOpen: (AppRoute) -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            KiraIconButton.back("plan.back", action: onBack)
            Spacer()
            VStack(spacing: KiraSpacing.space3) {
                KiraIllustration(.cardPaidOff, size: 128)
                Text("plan.empty.title").kiraFont(.title).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
                Text("plan.empty.body").kiraFont(.callout).foregroundStyle(.inkMuted)
                KiraButton("plan.empty.cta") { onOpen(.payoffSimulation) }.block()
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(KiraSpacing.screen)
    }
}
