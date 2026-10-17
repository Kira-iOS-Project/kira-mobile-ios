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
                content(nil, onSeller: { _ in })
            case .loaded(let product):
                content(product) { openURL($0) }
            case .empty:
                gone
            case .failed(let problem):
                failed(problem)
            }
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }

    private func content(_ product: Product?, onSeller: @escaping (URL) -> Void) -> some View {
        ProductContent(
            product: product ?? .sample(.course), isPlaceholder: product == nil, onBack: { dismiss() },
            onHelp: { onOpen(.care) }, onSeller: onSeller)
    }

    /** The nav bar stays, so the person can go back from a product that did not load. */
    private func failed(_ problem: AppProblem) -> some View {
        VStack(spacing: 0) {
            navBar
            LoadFailedView(title: "product.failed", problem: problem) { Task { await model.load() } }
        }
    }

    /** COMMUNITY_PRODUCT_NOT_FOUND: no Coba Lagi, which could never bring it back; the way back instead. */
    private var gone: some View {
        VStack(spacing: 0) {
            navBar
            VStack(spacing: KiraSpacing.space4) {
                KiraIllustration(.care, size: 112)
                Text("product.failed").kiraFont(.title).foregroundStyle(.ink).multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text("problem.COMMUNITY_PRODUCT_NOT_FOUND").kiraFont(.callout).foregroundStyle(.inkMuted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                KiraButton("product.back") { dismiss() }.block()
            }
            .padding(KiraSpacing.screen)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var navBar: some View {
        KiraNavBar("product.title", leading: .back("product.back") { dismiss() }) {
            KiraHelpButton(.icon) { onOpen(.care) }
        }
        .padding(.horizontal, KiraSpacing.screen)
        .padding(.top, 62 - 59)
    }
}

/** The loaded product, top to bottom as the board lays it. */
private struct ProductContent: View {
    let product: Product
    /** While loading: the shape of a product, redacted, hidden from VoiceOver, without its notices. */
    let isPlaceholder: Bool
    let onBack: () -> Void
    let onHelp: () -> Void
    let onSeller: (URL) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "product.title", subtitle: isPlaceholder ? nil : product.summary.kind.title,
                    leading: .back("product.back", onBack)
                ) {
                    KiraHelpButton(.icon, action: onHelp)
                }
                if isPlaceholder {
                    details.redacted(reason: .placeholder).disabled(true).accessibilityHidden(true)
                } else {
                    details
                }
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, 62 - 59)
            .padding(.bottom, KiraSpacing.screenBottom)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 130, isFlipped: true).offset(x: 38, y: 34 - 59)
                    .accessibilityHidden(true)
            }
        }
        .kiraScrollEdges()
    }

    @ViewBuilder private var details: some View {
        ProductSummaryCard(product: product)
        ProductContentsList(product: product)
        if !isPlaceholder {
            if product.affiliate {
                KiraNotice(.info, title: "product.affiliate.title", message: "product.affiliate.body")
            }
            if product.investmentRisk {
                KiraNotice(.warning, title: "product.risk.title", message: "product.risk.body")
            }
            KiraNotice(.education, title: "marketplace.education.title", message: product.summary.kind.educationMessage)
            sellerButton.padding(.top, KiraSpacing.space1)
        }
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
