/**
 Detail Produk (KOM-07 Kursus, 07b Konsultasi, 07c E-Book, 07d Event): one template for the four
 kinds. The seller and their badge, the price or "Gratis", what the product holds, the affiliate
 disclosure when Kira earns a commission, the risk warning for investing products, the education
 notice, and "Buka Halaman Penjual", which opens the seller's page in the system browser. Kira
 never takes the payment. Opened by `AppRoute.product(id:)`.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct ProductScreen: View {
    @State private var model: ProductModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    init(id: String, service: any MarketplaceService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: ProductModel(id: id, service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        Group {
            switch model.phase {
            case .loading:
                content(.sample(.course), onSeller: { _ in })
                    .redacted(reason: .placeholder)
                    .disabled(true)
            case .loaded(let product):
                content(product) { openURL($0) }
            case .empty:
                failed(AppProblem())
            case .failed(let problem):
                failed(problem)
            }
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }

    private func content(_ product: Product, onSeller: @escaping (URL) -> Void) -> some View {
        ProductContent(
            product: product, onBack: { dismiss() }, onHelp: { onOpen(.unavailable(.care)) }, onSeller: onSeller)
    }

    /** The nav bar stays, so the person can go back from a product that is gone. */
    private func failed(_ problem: AppProblem) -> some View {
        VStack(spacing: 0) {
            KiraNavBar("product.title", leading: .back("product.back") { dismiss() }) {
                KiraHelpButton(.icon) { onOpen(.unavailable(.care)) }
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, 62 - 59)
            LoadFailedView(title: "product.failed", problem: problem) { Task { await model.load() } }
        }
    }
}

/** The loaded product, top to bottom as the board lays it. */
private struct ProductContent: View {
    let product: Product
    let onBack: () -> Void
    let onHelp: () -> Void
    let onSeller: (URL) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "product.title", subtitle: product.summary.kind.title, leading: .back("product.back", onBack)
                ) {
                    KiraHelpButton(.icon, action: onHelp)
                }
                ProductSummaryCard(product: product)
                ProductContentsList(product: product)
                if product.affiliate {
                    KiraNotice(.info, title: "product.affiliate.title", message: "product.affiliate.body")
                }
                if product.investmentRisk {
                    KiraNotice(.warning, title: "product.risk.title", message: "product.risk.body")
                }
                KiraNotice(.education, title: "marketplace.education.title", message: product.summary.kind.educationMessage)
                sellerButton.padding(.top, KiraSpacing.space1)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, 62 - 59)
            .padding(.bottom, KiraSpacing.space8)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 130, isFlipped: true).offset(x: 38, y: 34 - 59)
                    .accessibilityHidden(true)
            }
        }
        .kiraScrollEdges()
    }

    /** Opens the seller's page; while the team checks it again, disabled with the reason under it. */
    @ViewBuilder private var sellerButton: some View {
        if let url = product.sellerURL {
            KiraButton("product.seller") { onSeller(url) }.iconEnd(.external).block()
        } else {
            VStack(spacing: KiraSpacing.space2) {
                KiraButton("product.seller") {}.iconEnd(.external).block().disabled(true)
                Text("product.seller.checking")
                    .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
