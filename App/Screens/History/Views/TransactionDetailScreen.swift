/**
 Detail Transaksi (CAT-08): the category tile, name and amount, then the details card, then Ubah
 and Hapus. Hapus asks first (08b) and reports the result (08c, 08e); Ubah opens the "Ubah
 Transaksi" sheet: its success shows over it (08d), a failed save closes it for its dialog (08e). The Sumber row opens Riwayat
 Percakapan on the source message (08f).
 */
import Domain
import Features
import SwiftUI

struct TransactionDetailScreen: View {
    private let service: any HistoryService
    private let onOpen: (HistoryDestination) -> Void
    @State private var model: TransactionDetailModel
    @State private var openedMessageId: String?
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.dismiss) private var dismiss

    init(id: String, service: any HistoryService, onOpen: @escaping (HistoryDestination) -> Void) {
        self.service = service
        self.onOpen = onOpen
        _model = State(initialValue: TransactionDetailModel(id: id, service: service))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("transaction.title", leading: .back("transaction.back") { dismiss() }) {
                    KiraHelpButton(.icon) { onOpen(.help) }
                }
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.space4)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 52, y: -22)
            }
            .background(alignment: .topLeading) {
                KiraLeaf(.pandan, tone: .soft, size: 104).offset(x: -56, y: 88)
            }
        }
        /**
         The board pins Ubah and Hapus to the bottom, on the home indicator's padding alone; at the
         accessibility sizes they follow the card instead, so the detail keeps the screen.
         */
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if model.phase.value != nil, !typeSize.isAccessibilitySize {
                actions
                    .padding(.horizontal, KiraSpacing.screen)
                    .padding(.top, KiraSpacing.space2)
                    .background(.surface)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
        .onChange(of: model.isClosed) { _, isClosed in
            if isClosed { dismiss() }
        }
        .navigationDestination(item: $openedMessageId) { messageId in
            ConversationScreen(sourceMessageId: messageId, service: service)
        }
        .kiraSheet(
            $model.editSheet, title: "transaction.edit.title", subtitle: editSubtitle,
            failureTitle: "transaction.failed.title", connectionMessage: "transaction.failed.body",
            onRetry: { Task { await model.retryEdit() } }
        ) {
            TransactionEditForm(model: model)
        }
        .kiraDialog(isPresented: hasDialog) { TransactionDialogs.screen(model) }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading, .empty:
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, KiraSpacing.space8)
        case .loaded(let detail):
            loaded(detail)
        case .failed(let problem):
            LoadFailedView(problem: problem) { Task { await model.load() } }
        }
    }

    private func loaded(_ detail: TransactionDetail) -> some View {
        let transaction = detail.transaction
        return VStack(spacing: KiraSpacing.space4) {
            VStack(spacing: KiraSpacing.space1) {
                KiraCategoryIcon(transaction.category.tile, size: 52, label: transaction.category.title)
                Text(transaction.name)
                    .font(KiraFont.display(22, .heavy, relativeTo: .title2))
                    .kiraLineHeight(28, size: 22, natural: 1.26, relativeTo: .title2)
                    .tracking(-0.33)
                    .foregroundStyle(.ink)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                    .accessibilityAddTraits(.isHeader)
                KiraAmount(Decimal(transaction.amount), size: .extraLarge)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, KiraSpacing.space1)
            TransactionDetailCard(detail: detail) {
                openedMessageId = $0
            } editNote: {
                model.startEditing()
            }
            if typeSize.isAccessibilitySize { actions }
        }
    }

    private var actions: some View {
        KiraButtonPair(
            secondary: KiraButton("transaction.edit", variant: .secondary) { model.startEditing() }.icon(.pencil),
            primary: KiraButton("transaction.delete", variant: .destructive) { model.requestDelete() }.icon(.trash))
    }

    private var editSubtitle: LocalizedStringResource? {
        guard let quote = model.phase.value?.sourceMessage else { return nil }
        return "transaction.edit.subtitle \(quote.createdAt.formatted(.kiraTime))"
    }

    private var hasDialog: Binding<Bool> {
        Binding(get: { model.dialog != nil }, set: { if !$0 { model.dialogClosed() } })
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            TransactionDetailScreen(id: "grab", service: PreviewHistoryService(), onOpen: { _ in })
        }
    }
#endif
