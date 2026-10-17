/** Dompet (UNG-01): held money, running debt and due-soon accounts. */
import Domain
import Features
import SwiftUI

struct WalletsScreen: View {
    @State private var model: WalletsModel
    @State private var createModel: WalletCreateModel
    @State private var isAddingWallet = false
    @State private var pendingSavedWallet: Wallet?
    @State private var savedWallet: Wallet?
    private let onOpenDebt: (String) -> Void
    private let onOpenHelp: () -> Void

    init(service: any WalletService, onOpenDebt: @escaping (String) -> Void, onOpenHelp: @escaping () -> Void) {
        self.onOpenDebt = onOpenDebt
        self.onOpenHelp = onOpenHelp
        _model = State(initialValue: WalletsModel(service: service))
        _createModel = State(initialValue: WalletCreateModel(service: service))
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                    header
                    content
                }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.top, KiraSpacing.space2)
                .padding(.bottom, KiraSpacing.space10)
                .background(alignment: .topTrailing) {
                    KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 52, y: -22)
                }
            }
            .background(.surface)
            .kiraScrollEdges()
            .toolbar(.hidden, for: .navigationBar)
            .onAppear { Task { await model.load() } }
            .onChange(of: createModel.phase.value?.id) { _, _ in
                guard isAddingWallet, let wallet = createModel.phase.value else { return }
                model.walletAdded(wallet)
                pendingSavedWallet = wallet
                isAddingWallet = false
                withAnimation { proxy.scrollTo(wallet.id, anchor: .center) }
            }
            .onChange(of: isAddingWallet) { _, isPresented in
                if isPresented {
                    createModel.resetDraft()
                } else if let wallet = pendingSavedWallet {
                    pendingSavedWallet = nil
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(400))
                        guard !isAddingWallet else { return }
                        savedWallet = wallet
                    }
                }
            }
            .kiraSheet(isPresented: $isAddingWallet, title: "wallet.create.title") {
                WalletCreateSheet(model: createModel) { isAddingWallet = false }
            }
            .kiraDialog(isPresented: savedWalletPresented) {
                KiraDialog(
                    "wallet.create.saved.title", message: "wallet.create.saved.body", art: .illustration(.bloom),
                    primary: KiraButton("wallet.create.done") {})
            }
        }
    }

    private var savedWalletPresented: Binding<Bool> {
        Binding(
            get: { savedWallet != nil },
            set: { if !$0 { savedWallet = nil } }
        )
    }

    private var header: some View {
        KiraNavBar("wallet.title", leading: .back("wallet.back") { dismiss() }) {
            KiraHelpButton(.icon, action: onOpenHelp)
        }
    }

    @Environment(\.dismiss) private var dismiss

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            WalletOverviewContent(
                overview: WalletOverview(accounts: WalletPreviewData.accounts), model: model,
                add: {}, openDebt: { _ in }
            ).redacted(reason: .placeholder).disabled(true)
        case .empty: WalletEmptyContent(add: { isAddingWallet = true })
        case .loaded(let overview):
            WalletOverviewContent(
                overview: overview, model: model, add: { isAddingWallet = true }, openDebt: { onOpenDebt($0) })
        case .failed(let problem):
            LoadFailedView(title: "wallet.failed", problem: problem) { Task { await model.load() } }
        }
    }
}

private struct WalletEmptyContent: View {
    let add: () -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraIllustration(.sprout, size: 112)
            Text("wallet.empty.title").kiraFont(.title).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
            Text("wallet.empty.body").font(.body).foregroundStyle(.inkMuted).multilineTextAlignment(.center)
            KiraButton("wallet.create.open", action: add).block()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, KiraSpacing.space8)
    }
}
