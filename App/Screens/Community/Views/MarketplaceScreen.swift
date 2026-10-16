/**
 Etalase (KOM-06), from the Etalase card of Komunitas: the curated products as links to their
 sellers, filtered by kind, with "Punya Produk?" (KOM-08) and the education notice. A product opens
 `AppRoute.product(id:)`.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct MarketplaceScreen: View {
    @State private var model: MarketplaceModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(service: any MarketplaceService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: MarketplaceModel(service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "marketplace.title", subtitle: "marketplace.subtitle",
                    leading: .back("marketplace.back") { dismiss() }
                ) {
                    KiraHelpButton(.icon) { onOpen(.unavailable(.care)) }
                }
                KiraNotice(.info, message: "marketplace.notice")
                kindChips
                products
                SubmitProductCard { onOpen(.submitProduct) }
                KiraNotice(.education, title: "marketplace.education.title", message: "marketplace.education.body")
            }
            .padding(.horizontal, KiraSpacing.screen)
            /** The board's 62 pt from the top of the screen, and its twig at 34 pt. */
            .padding(.top, 62 - 59)
            .padding(.bottom, KiraSpacing.space8)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 130, isFlipped: true).offset(x: 38, y: 34 - 59)
                    .accessibilityHidden(true)
            }
        }
        .kiraScrollEdges()
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.appear() }
    }

    /** Semua, Kursus, Konsultasi, E-Book, Event. */
    private var kindChips: some View {
        KiraFlowRow {
            KiraChip("marketplace.kind.all", isSelected: model.kind == nil) { select(nil) }
            ForEach(ProductKind.allCases, id: \.self) { kind in
                KiraChip(kind.title, isSelected: model.kind == kind) { select(kind) }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("marketplace.kinds"))
    }

    private var products: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("marketplace.products", trailing: .note("marketplace.products.note"))
            switch model.phase {
            case .loading:
                /** The shape of three cards: hidden from VoiceOver, which would read the sample text. */
                ProductCardList(products: ProductSummary.samples.prefix(3)) { _ in }
                    .redacted(reason: .placeholder)
                    .disabled(true)
                    .accessibilityHidden(true)
            case .loaded(let products):
                ProductCardList(products: products[...]) { onOpen(.product(id: $0.id)) }
            case .empty:
                Text(model.kind == nil ? "marketplace.empty.all" : "marketplace.empty")
                    .font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
                    .frame(maxWidth: .infinity)
                    .padding(KiraSpacing.space5)
                    .kiraCard()
            case .failed(let problem):
                LoadFailedView(problem: problem) { Task { await model.load() } }
            }
        }
        .padding(.top, KiraSpacing.space1)
    }

    private func select(_ kind: ProductKind?) {
        Task { await model.select(kind) }
    }
}

/** The product cards, in the order given. */
private struct ProductCardList: View {
    let products: ArraySlice<ProductSummary>
    let onSelect: (ProductSummary) -> Void

    var body: some View {
        ForEach(products) { product in
            ProductCard(product: product) { onSelect(product) }
        }
    }
}
