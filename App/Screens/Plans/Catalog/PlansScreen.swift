/**
 Paket Kira (AKN-06, AKN-06d; boards Paket, PaketTahunan): the three plans with honest prices,
 Bulanan or Tahunan, what stays free, the promises and Beasiswa Kira. The entry of the plans flow:
 the details, Bayar, Traktir Kira and Beasiswa Kira open on the caller's navigation stack; leaving
 the flow goes through `onOpen`.
 */
import Domain
import Features
import SwiftUI

struct PlansScreen: View {
    /** A page this flow pushes. */
    enum Page: Hashable {
        case detail(PlanTerms)
        case checkout(PlanTerms, BillingPeriod)
        case treat
        case scholarship
    }

    private let service: any PlansService
    private let onOpen: (AppRoute) -> Void
    @State private var model: PlansModel
    @State private var page: Page?
    @Environment(\.dismiss) private var dismiss

    init(service: any PlansService, onOpen: @escaping (AppRoute) -> Void, period: BillingPeriod = .monthly) {
        self.service = service
        self.onOpen = onOpen
        _model = State(initialValue: PlansModel(service: service, period: period))
    }

    var body: some View {
        PlansScreenFrame(leaf: .standard(size: 150)) {
            KiraNavBar("plans.title", leading: .close("plans.close") { dismiss() }) {
                KiraHelpButton(.icon) { onOpen(.unavailable(.care)) }
            }
            PlansDisplayTitle("plans.headline", size: 28, tracking: 0.02)
                .padding(EdgeInsets(top: 8, leading: 4, bottom: 0, trailing: 4))
            Text("plans.lede").font(.body).kiraLineHeight(24, size: 17).foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1).padding(.bottom, KiraSpacing.space1)
            KiraSegmented(
                "plans.period",
                options: [
                    .init(id: .monthly, title: "plans.period.monthly"),
                    .init(id: .yearly, title: "plans.period.yearly"),
                ],
                selection: $model.period)
            content
        }
        .task { await model.load() }
        .navigationDestination(item: $page) { destination($0) }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading, .empty:
            PlansLoadingView()
        case .failed(let problem):
            PlansProblemView(problem: problem) { Task { await model.load() } }
        case .loaded(let catalog):
            PlanCards(catalog: catalog, period: model.period) { page = .detail($0) }
            PlansPromises(
                onScholarship: { page = .scholarship }, onLater: { dismiss() },
                onTry: { tryPlus(catalog) })
        }
    }

    private func tryPlus(_ catalog: PlanCatalog) {
        if let plus = catalog.terms(for: .plus) { page = .checkout(plus, model.period) }
    }

    @ViewBuilder private func destination(_ page: Page) -> some View {
        switch page {
        case .detail(let terms):
            PlanDetailView(terms: terms, period: model.period, service: service, onOpen: onOpen)
        case .checkout(let terms, let period):
            CheckoutView(terms: terms, period: period, service: service) { onOpen(.subscription) }
        case .treat:
            TreatView(service: service)
        case .scholarship:
            ScholarshipScreen(service: service, onOpen: onOpen)
        }
    }
}

#Preview {
    NavigationStack { PlansScreen(service: PreviewPlansService(), onOpen: { _ in }) }
}
