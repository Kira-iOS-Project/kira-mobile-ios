/**
 Rencanaku (SKR-04, board PelunasanAktif): the account being paid off on the hero, the payment to
 make next with Tandai Sudah Bayar, every account with its tag, and Ubah Rencana back to Rencana
 Pelunasan. The payment that settles an account opens Perayaan Lunas (SKR-05) over the page, once.
 A payment or a move that fails shows the failure dialog: Coba Lagi sends it again, Tutup leaves the
 plan as it was.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct PayoffPlanScreen: View {
    @State private var model: PayoffPlanModel
    /** Where the celebration leads once it has gone. */
    @State private var exit: CelebrationExit?
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
        .fullScreenCover(item: $model.celebration, onDismiss: leaveCelebration) { paid in
            PayoffCelebration(paid: paid) { chosen in
                exit = chosen
                model.dismissCelebration()
            }
        }
        .kiraDialog(isPresented: failing) {
            PayoffPlanFailureDialog.make(model.failure) { failed in Task { await model.retry(failed) } }
        }
    }

    private var failing: Binding<Bool> {
        Binding(get: { model.failure != nil }, set: { if !$0 { model.failure = nil } })
    }

    /** Runs once the celebration is down, so the move's own failure dialog never meets it on its way. */
    private func leaveCelebration() {
        let chosen = exit
        exit = nil
        switch chosen {
        case .next(let paid): Task { await model.continueToNext(after: paid) }
        case .home: onOpen(.home)
        case .score: onOpen(.score)
        case nil: break
        }
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
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("plan.title", subtitle: PayoffPlanCopy.subtitle(plan), leading: .back("plan.back", onBack)) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                if let focus = plan.focus {
                    PayoffPlanHero(plan: plan, account: focus)
                }
                if let next = plan.nextPayment {
                    PayoffNextPaymentCard(
                        payment: next, category: plan.account(next.debtId)?.kind.category ?? .paylater,
                        isWorking: model.isWorking
                    ) { Task { await model.markPaid() } }
                } else {
                    PayoffPlanDoneCard { onOpen(.score) }
                }
                PayoffPlanAccounts(plan: plan) { _ in onOpen(.unavailable(.debtDetail)) }
                KiraButton("plan.edit", variant: .secondary) { onOpen(.payoffSimulation) }.icon(.pencil).block()
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.space8)
            .frame(maxWidth: .infinity, alignment: .top)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 130, isFlipped: true)
                    .offset(x: 38, y: -28)
                    .accessibilityHidden(true)
            }
        }
        .kiraScrollEdges()
    }
}

/** Before a plan is made: what Rencanaku is, and the way to Rencana Pelunasan. */
private struct PayoffPlanEmptyView: View {
    let onOpen: (AppRoute) -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            KiraNavBar("plan.title", leading: .back("plan.back", onBack)) {
                KiraHelpButton(.icon) { onOpen(.care) }
            }
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
        .padding(.horizontal, KiraSpacing.screen)
        .padding(.vertical, KiraSpacing.space2)
    }
}

/** The failure dialog of a payment or a move (the sheet-failure pattern's dialog). */
enum PayoffPlanFailureDialog {
    static func make(_ failure: PayoffPlanModel.Failure?, retry: @escaping (PayoffPlanModel.Failure) -> Void)
        -> KiraDialog
    {
        let title: LocalizedStringResource =
            switch failure {
            case .focus: "plan.failure.focus"
            default: "plan.failure.payment"
            }
        return KiraDialog(
            title, message: message(failure?.problem), art: .illustration(.umbrella),
            primary: KiraButton("plan.failure.retry") { if let failure { retry(failure) } },
            secondary: KiraButton("plan.failure.close", variant: .secondary) {})
    }

    /** The connection's sentence for a request that got no answer, the reference for an unknown problem, else the problem's. */
    private static func message(_ problem: AppProblem?) -> LocalizedStringResource {
        guard let problem else { return "problem.connection" }
        if problem.isConnectionLoss { return "problem.connection" }
        if problem.showsReference { return "sheet.failure.reference \(problem.reference)" }
        return problem.message
    }
}
