/** Dompet (UNG-01): held money, running debt and due-soon accounts. */
import Domain
import Features
import SwiftUI

struct WalletsScreen: View {
    @State private var model: WalletsModel
    @State private var adding: AddWalletModel
    private let onOpenDebt: (String) -> Void
    private let onOpenHelp: () -> Void
    /** Whether Tambah Dompet opens as the screen appears (the debug launcher's audits). */
    private let startsAdding: Bool

    init(
        service: any WalletService, onOpenDebt: @escaping (String) -> Void, onOpenHelp: @escaping () -> Void,
        startsAdding: Bool = false
    ) {
        self.startsAdding = startsAdding
        self.onOpenDebt = onOpenDebt
        self.onOpenHelp = onOpenHelp
        _model = State(initialValue: WalletsModel(service: service))
        _adding = State(initialValue: AddWalletModel(service: service))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                header
                content
                KiraButton("wallet.add.button") { adding.open() }.icon(.plus).block()
                    .padding(.top, KiraSpacing.space2)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.space10)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 52, y: -22)
                    .accessibilityHidden(true)
            }
            .background(alignment: .bottomLeading) {
                KiraLeaf(.pandan, tone: .soft, size: 120).offset(x: -44, y: 18).accessibilityHidden(true)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            Task { await model.load() }
            if startsAdding { adding.open() }
        }
        .addWalletSheet(adding) { Task { await model.load() } }
    }

    private var header: some View {
        KiraNavBar("wallet.title", subtitle: subtitle, leading: .back("wallet.back") { dismiss() }) {
            KiraHelpButton(.icon, action: onOpenHelp)
        }
    }

    @Environment(\.dismiss) private var dismiss

    /** "4 dompet · 3 akun utang", once the accounts are loaded. */
    private var subtitle: LocalizedStringResource? {
        guard case .loaded(let overview) = model.phase else { return nil }
        return "wallet.subtitle \(overview.wallets.count) \(overview.debts.count)"
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            WalletOverviewContent(
                overview: WalletOverview(accounts: WalletPreviewData.accounts), model: model,
                openDebt: { _ in }
            ).redacted(reason: .placeholder).disabled(true)
        case .empty: WalletEmptyContent()
        case .loaded(let overview):
            WalletOverviewContent(
                overview: overview, model: model, openDebt: { onOpenDebt($0) })
        case .failed(let problem):
            LoadFailedView(title: "wallet.failed", problem: problem) { Task { await model.load() } }
        }
    }
}

private struct WalletEmptyContent: View {
    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraIllustration(.sprout, size: 112)
            Text("wallet.empty.title").kiraFont(.title).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
            Text("wallet.empty.body").font(.body).foregroundStyle(.inkMuted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, KiraSpacing.space8)
    }
}
