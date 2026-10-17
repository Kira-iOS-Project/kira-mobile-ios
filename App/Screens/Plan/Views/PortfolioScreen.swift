/**
 Portofolio Manual (REN-10, board Portofolio): the total with its eye and composition, "Asetmu",
 "Dampak ke Kira Score", the privacy and education notices, and Tambah Aset at the bottom. Values
 are the person's own: Kira is not connected to any investment account and shows no market price.
 It loads each time it shows, so Tambah Aset's save is there on the way back.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct PortfolioScreen: View {
    @State private var model: PortfolioModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(service: any PortfolioService, startsMasked: Bool = false, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: PortfolioModel(service: service, isMasked: startsMasked))
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("portfolio.title", leading: .back("portfolio.back") { dismiss() }) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space1)
            .padding(.bottom, KiraSpacing.screenBottom)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 136, isFlipped: true)
                    .offset(x: 40, y: -36)
                    .accessibilityHidden(true)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, KiraSpacing.space8)
        case .empty:
            KiraNotice(.info, title: "portfolio.empty.title", message: "portfolio.empty.body")
            notices
            addButton
        case .loaded(let portfolio):
            PortfolioTotalCard(model: model, portfolio: portfolio)
            PortfolioAssetList(model: model, assets: portfolio.assets, onOpen: onOpen)
            if let impact = portfolio.debtToAsset { PortfolioImpactCard(impact: impact, onOpen: onOpen) }
            notices
            addButton
        case .failed(let problem) where model.needsPlan:
            PlanGateNotice(problem: problem) { onOpen(.plans(yearly: false)) }
        case .failed(let problem):
            LoadFailedView(title: "portfolio.failed", problem: problem) { Task { await model.load() } }
                .padding(.vertical, KiraSpacing.space8)
        }
    }

    private var notices: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraNotice(.privacy, message: "portfolio.privacy")
            KiraNotice(.education, title: "portfolio.education.title", message: "portfolio.education.body")
        }
    }

    private var addButton: some View {
        KiraButton("portfolio.add") { onOpen(.addAsset) }
            .icon(.plus)
            .block()
            .padding(.top, KiraSpacing.space1)
    }
}

#Preview {
    NavigationStack { PortfolioScreen(service: PreviewPortfolioService(), onOpen: { _ in }) }
}
