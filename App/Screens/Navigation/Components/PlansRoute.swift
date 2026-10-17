/**
 The Plans routes. Paket, Langganan and Beasiswa Kira load their own data; a plan's detail, its
 payment and Metode Pembayaran need a plan's terms or the current method first, which
 `RouteLoadModel` fetches.
 */
import Domain
import Features
import SwiftUI

struct PlansRoute: View {
    let route: AppRoute
    let service: any PlansService
    let onOpen: (AppRoute) -> Void

    var body: some View {
        switch route {
        case .plans(let yearly): PlansScreen(service: service, onOpen: onOpen, period: yearly ? .yearly : .monthly)
        case .planDetail(let plan):
            PlanTermsRoute(plan: plan, service: service, back: "plans.detail.back") { terms in
                PlanDetailView(terms: terms, period: .monthly, service: service, onOpen: onOpen)
            }
        case .checkout(let plan, let yearly):
            PlanTermsRoute(plan: plan, service: service, back: "checkout.back") { terms in
                CheckoutView(terms: terms, period: yearly ? .yearly : .monthly, service: service) {
                    onOpen(.subscription)
                }
            }
        case .paymentMethod: PaymentMethodRoute(service: service)
        case .invoices: InvoicesView(service: service)
        case .treat: TreatView(service: service)
        case .scholarshipApply:
            ScholarshipApplyView(service: service, onOpen: onOpen) { onOpen(.scholarshipStatus) }
        case .scholarship, .scholarshipStatus: ScholarshipScreen(service: service, onOpen: onOpen)
        default: SubscriptionScreen(service: service, onOpen: onOpen)
        }
    }
}

/** A plan's terms from `GET /plans`, then the screen built from them. */
private struct PlanTermsRoute<Content: View>: View {
    @State private var model: RouteLoadModel<PlanTerms>
    private let back: LocalizedStringResource
    private let content: (PlanTerms) -> Content

    init(
        plan: PlanID, service: any PlansService, back: LocalizedStringResource,
        @ViewBuilder content: @escaping (PlanTerms) -> Content
    ) {
        _model = State(initialValue: RouteLoadModel { try await service.plans().plans.first { $0.id == plan } })
        self.back = back
        self.content = content
    }

    var body: some View {
        RouteLoadView(model: model, back: back, content: content)
    }
}

/** Metode Pembayaran, opened with the subscription's current method. */
private struct PaymentMethodRoute: View {
    @State private var model: RouteLoadModel<Subscription>
    private let service: any PlansService

    init(service: any PlansService) {
        _model = State(initialValue: RouteLoadModel { try await service.subscription() })
        self.service = service
    }

    var body: some View {
        RouteLoadView(model: model, back: "method.back") { subscription in
            PaymentMethodView(current: subscription.paymentMethod, service: service) {}
        }
    }
}

/**
 A spinner while the route loads, the problem with Coba Lagi when it failed, then the screen. Until
 the screen shows, the way back is the screen's own Kira back button (`back`, "Kembali ke …"), never
 the system bar's chevron.
 */
private struct RouteLoadView<Value: Sendable, Content: View>: View {
    let model: RouteLoadModel<Value>
    let back: LocalizedStringResource
    @ViewBuilder let content: (Value) -> Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            switch model.phase {
            case .loading: waiting { PlansLoadingView() }
            case .empty: EmptySlot()
            case .loaded(let value): content(value)
            case .failed(let problem):
                waiting {
                    PlansProblemView(problem: problem) { Task { await model.load() } }.padding(KiraSpacing.screen)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.loadIfNeeded() }
    }

    /** `state` under the Kira back button, top left, as the screen's bar will show it. */
    private func waiting(@ViewBuilder _ state: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            KiraIconButton.back(back) { dismiss() }
                .padding(.horizontal, KiraSpacing.screen).padding(.top, KiraSpacing.space2)
            state().frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(.surface)
    }
}
