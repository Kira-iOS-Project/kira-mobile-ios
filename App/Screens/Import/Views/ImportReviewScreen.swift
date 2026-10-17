/**
 Tinjau Hasil Impor (CAT-12): how many transactions the file holds, the likely duplicates
 unchecked under "Mungkin Dobel" (a tap checks one), the rest checked under "Siap Disimpan" (a tap
 opens the row to change its category or leave it out), then Batal and "Simpan N Transaksi". The
 save reports "N Transaksi Tersimpan" (12b) or "Impor Belum Berhasil" with Coba Lagi (12c).
 */
import APIClient
import Domain
import Features
import SwiftUI

struct ImportReviewScreen: View {
    private let onOpen: (HistoryDestination) -> Void
    private let onFinish: () -> Void
    @State private var model: ImportReviewModel
    @Environment(\.dismiss) private var dismiss

    init(
        preview: ImportPreview, fileName: String, service: any HistoryService,
        onOpen: @escaping (HistoryDestination) -> Void, onFinish: @escaping () -> Void
    ) {
        self.onOpen = onOpen
        self.onFinish = onFinish
        _model = State(initialValue: ImportReviewModel(preview: preview, fileName: fileName, service: service))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("review.title", leading: .back("review.back") { dismiss() }) {
                    KiraHelpButton(.icon) { onOpen(.help) }
                }
                KiraStepProgress(current: 3, total: 3, label: "review.step")
                summary
                if !model.duplicates.isEmpty {
                    KiraNotice(.info, message: "review.duplicates.notice \(model.duplicates.count)")
                }
                ImportReviewGroups(model: model)
                buttons.padding(.top, KiraSpacing.space2)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.space2)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 52, y: -22)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: model.isFinished) { _, isFinished in
            if isFinished { onFinish() }
        }
        .kiraSheet(isPresented: isEditing, title: "review.row.title", subtitle: editingSubtitle) {
            ImportRowSheet(model: model)
        }
        .kiraDialog(isPresented: hasDialog) { dialog }
    }

    private var summary: some View {
        HStack(spacing: 14) {
            KiraCategoryIcon(.bank, size: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text("review.found \(model.preview.rows.count)")
                    .font(KiraFont.display(22, .heavy, relativeTo: .title2))
                    .kiraLineHeight(28, size: 22, natural: 1.26, relativeTo: .title2)
                    .tracking(-0.33)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("review.source \(days) \(model.fileName)")
                    .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, KiraSpacing.space4)
        .kiraCard()
    }

    private var days: String {
        DayRange(first: model.preview.dateFrom, last: model.preview.dateTo).formatted(.kiraDayRange)
    }

    private var buttons: some View {
        HStack(spacing: KiraSpacing.space2) {
            KiraButton("review.cancel", variant: .secondary, action: onFinish)
            KiraButton("review.save \(model.checkedCount)") { Task { await model.save() } }
                .block()
                .disabled(model.checkedCount == 0 || model.isSaving)
        }
    }

    private var dialog: KiraDialog {
        switch model.shownDialog {
        case .saved(let result):
            KiraDialog(
                "review.saved.title \(result.savedCount)",
                message: result.skippedCount > 0
                    ? "review.saved.bodySkipped \(result.skippedCount)" : "review.saved.body",
                art: .illustration(.bloom), primary: KiraButton("review.saved.history") {})
        case .failed(let problem):
            KiraDialog(
                "review.failed.title", message: Self.failedMessage(problem), art: .illustration(.umbrella),
                primary: KiraButton("review.failed.retry") { Task { await model.save() } },
                secondary: KiraButton("review.failed.close", variant: .secondary) {})
        }
    }

    /** The board's sentence for a lost connection (nothing saved, so no double), else the API's problem. */
    private static func failedMessage(_ problem: AppProblem) -> LocalizedStringResource {
        if problem.isConnectionLoss { return "review.failed.body" }
        if problem.showsReference { return "sheet.failure.reference \(problem.reference)" }
        return problem.message
    }

    private var editingSubtitle: LocalizedStringResource? {
        guard let row = model.editingRow else { return nil }
        return "review.row.subtitle \(row.day.date.formatted(.kiraDate))"
    }

    private var isEditing: Binding<Bool> {
        Binding(get: { model.editingRowId != nil }, set: { if !$0 { model.editingRowId = nil } })
    }

    private var hasDialog: Binding<Bool> {
        Binding(get: { model.dialog != nil }, set: { if !$0 { model.dialogClosed() } })
    }
}
