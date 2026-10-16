/**
 Langganan (AKN-07, AKN-07b, AKN-07c; boards KelolaLangganan*): the plan with its renewal and
 reminder dates, the month's quotas, Ganti Paket, Metode Pembayaran, Riwayat Tagihan, Traktir Kira
 and the one-tap cancel behind one confirmation. The entry of the subscription flow: its pages open
 on the caller's navigation stack; Ganti Paket and the help button go through `onOpen`.
 */
import Domain
import Features
import SwiftUI

struct SubscriptionScreen: View {
    /** A page this flow pushes. */
    enum Page: Hashable {
        case paymentMethod(PaymentMethod?)
        case invoices
        case treat
    }

    private let service: any PlansService
    private let onOpen: (AppRoute) -> Void
    @State private var model: SubscriptionModel
    @State private var page: Page?
    @State private var confirmsCancel = false
    @Environment(\.dismiss) private var dismiss

    init(service: any PlansService, onOpen: @escaping (AppRoute) -> Void) {
        self.service = service
        self.onOpen = onOpen
        _model = State(initialValue: SubscriptionModel(service: service))
    }

    var body: some View {
        PlansScreenFrame {
            KiraNavBar("subscription.title", leading: .back("subscription.back") { dismiss() }) {
                KiraHelpButton(.icon) { onOpen(.unavailable(.care)) }
            }
            content
        }
        .task { await model.load() }
        .navigationDestination(item: $page) { destination($0) }
        .kiraDialog(isPresented: $confirmsCancel) {
            KiraDialog(
                "subscription.cancel.confirm.title", message: "subscription.cancel.confirm.body",
                art: .illustration(.care),
                primary: KiraButton("subscription.cancel", variant: .destructive) { Task { await model.cancel() } },
                secondary: KiraButton("subscription.cancel.keep", variant: .secondary) {})
        }
        .kiraDialog(isPresented: $model.didCancel) {
            KiraDialog(
                "subscription.cancel.done.title", message: "subscription.cancel.done.body", art: .illustration(.bloom),
                primary: KiraButton("subscription.done") {})
        }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            PlansLoadingView()
        case .empty:
            KiraNotice(.info, title: "subscription.free.title", message: "subscription.free.body")
            KiraButton("subscription.free.plans") { onOpen(.plans(yearly: false)) }.block()
        case .failed(let problem):
            PlansProblemView(problem: problem) { Task { await model.load() } }
        case .loaded(let subscription):
            SubscriptionHero(subscription: subscription)
            SubscriptionQuotas(usage: subscription.usage)
            rows(subscription)
            cancelSection(subscription)
        }
    }

    @ViewBuilder private func rows(_ subscription: Subscription) -> some View {
        KiraListGroup("subscription.manage") {
            KiraListRow(Text("subscription.change"), leading: .icon(.star)) {
                onOpen(.plans(yearly: subscription.period == .yearly))
            }
            .subtitle(Text("subscription.change.detail"))
            KiraListRow(Text("subscription.method"), leading: .icon(.card)) {
                page = .paymentMethod(subscription.paymentMethod)
            }
            .value(Text(subscription.paymentMethod?.title ?? "subscription.method.none"))
            KiraListRow(Text("subscription.invoices"), leading: .icon(.receipt)) { page = .invoices }
                .subtitle(Text("subscription.invoices.detail"))
        }
        KiraListGroup {
            KiraListRow(Text("plans.treat.row"), leading: .icon(.gift)) { page = .treat }
                .subtitle(Text("subscription.treat.detail"))
        }
        .accessibilityLabel(Text("plans.treat.row"))
    }

    @ViewBuilder private func cancelSection(_ subscription: Subscription) -> some View {
        if !subscription.cancelAtPeriodEnd {
            VStack(spacing: 10) {
                KiraButton("subscription.cancel", variant: .secondary) { confirmsCancel = true }.block()
                    .disabled(model.isCancelling)
                cancelNote(subscription)
                    .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                    .multilineTextAlignment(.center).padding(.horizontal, KiraSpacing.space3)
                if let problem = model.cancelProblem { PlansProblemNotice(problem: problem) }
            }
            .padding(.top, KiraSpacing.space2)
        }
    }

    private func cancelNote(_ subscription: Subscription) -> Text {
        let plan = Text(subscription.plan.shortTitle)
        return Text("subscription.cancel.note \(plan) \(subscription.renewsOn.date, format: .plansFullDay)")
    }

    @ViewBuilder private func destination(_ page: Page) -> some View {
        switch page {
        case .paymentMethod(let current):
            PaymentMethodView(current: current, service: service) { Task { await model.load() } }
        case .invoices:
            InvoicesView(service: service)
        case .treat:
            TreatView(service: service)
        }
    }
}

#Preview {
    NavigationStack { SubscriptionScreen(service: PreviewPlansService(), onOpen: { _ in }) }
}
