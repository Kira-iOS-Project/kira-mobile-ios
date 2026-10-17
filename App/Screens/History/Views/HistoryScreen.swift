/**
 Riwayat Transaksi (CAT-07), the entry of the history flow: the pay period's transactions with
 search, the Semua/Keluar/Masuk segments, the period's totals, category chips and the days. A row
 opens Detail Transaksi (CAT-08), the upload button Impor Mutasi (CAT-11). It is pushed inside
 the caller's NavigationStack and pushes its own screens onto it; it reloads each time it shows
 again, so an edit, a delete or an import is in the list on return.
 */
import Domain
import Features
import SwiftUI

struct HistoryScreen: View {
    private let service: any HistoryService
    private let onOpen: (HistoryDestination) -> Void
    @State private var model: HistoryModel
    @State private var openedTransactionId: String?
    @State private var isImporting = false
    @Environment(\.dismiss) private var dismiss

    init(service: any HistoryService, onOpen: @escaping (HistoryDestination) -> Void) {
        self.init(model: HistoryModel(service: service), service: service, onOpen: onOpen)
    }

    /** The screen on a given model, for previews that fix the clock. */
    init(model: HistoryModel, service: any HistoryService, onOpen: @escaping (HistoryDestination) -> Void) {
        self.service = service
        self.onOpen = onOpen
        _model = State(initialValue: model)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                navBar
                HistoryFilters(model: model)
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.screenBottom)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 52, y: -22)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
        .task(id: model.searchText) { await model.searchChanged() }
        .navigationDestination(item: $openedTransactionId) { id in
            TransactionDetailScreen(id: id, service: service, onOpen: onOpen)
        }
        .navigationDestination(isPresented: $isImporting) {
            StatementImportScreen(service: service, onOpen: onOpen) { isImporting = false }
        }
    }

    private var navBar: some View {
        KiraNavBar("history.title", subtitle: subtitle, leading: .back("history.back") { dismiss() }) {
            KiraIconButton(.upload, label: "history.import", variant: .outline) {
                switch model.importEntry {
                case .importer: isImporting = true
                case .plans: onOpen(.plans)
                }
            }
            KiraHelpButton(.icon) { onOpen(.help) }
        }
    }

    private var subtitle: LocalizedStringResource? {
        guard let period = model.phase.value?.period else { return nil }
        return "history.period \(DayRange(period).formatted(.kiraDayRange))"
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, KiraSpacing.space8)
        case .empty:
            HistoryEmptyView()
        case .loaded(let content):
            HistoryList(content: content, model: model) { openedTransactionId = $0.id }
        case .failed(let problem):
            LoadFailedView(problem: problem) { Task { await model.load() } }
        }
    }
}

/** The period has no transaction yet. */
private struct HistoryEmptyView: View {
    var body: some View {
        VStack(spacing: KiraSpacing.space3) {
            KiraMascot(.calm, size: 132)
            Text("history.empty.title").kiraFont(.title).foregroundStyle(.ink)
            Text("history.empty.body")
                .font(.body).kiraLineHeight(22, size: 17)
                .foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, KiraSpacing.space8)
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            HistoryScreen(
                model: HistoryModel(service: PreviewHistoryService(), now: { PreviewHistoryData.now }),
                service: PreviewHistoryService(), onOpen: { _ in })
        }
    }
#endif
