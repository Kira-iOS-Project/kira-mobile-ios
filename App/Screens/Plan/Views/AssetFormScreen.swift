/**
 Tambah Aset (REN-11, board TambahAset), and the same form updating an asset from Portofolio: the
 class grid, Nama, Nilai Sekarang typed in whole rupiah (grouped as it is typed, ",00" after it),
 Tanggal, the notice that the value is the person's own, and Simpan Aset. A saved asset shows
 "Aset Tersimpan" (REN-11b), whose Selesai goes back to Portofolio. The form is a full screen, not a
 sheet, so a failed save closes nothing: "Belum Berhasil Menyimpan" with Coba Lagi and Tutup, every
 field kept. What is missing is said under its field.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct AssetFormScreen: View {
    @State private var model: AssetFormModel
    @Environment(\.dismiss) private var dismiss

    init(service: any PortfolioService, assetId: String? = nil) {
        _model = State(initialValue: AssetFormModel(service: service, assetId: assetId))
    }

    var body: some View {
        Group {
            switch model.phase {
            case .loading, .empty:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded:
                form
            case .failed(let problem):
                VStack(alignment: .leading) {
                    navBar
                    LoadFailedView(title: "asset.failed.load", problem: problem) { Task { await model.load() } }
                }
                .padding(.horizontal, KiraSpacing.screen)
            }
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
        .onChange(of: model.isClosed) { _, closed in if closed { dismiss() } }
        .kiraDialog(isPresented: $model.showsSaved) {
            KiraDialog(
                "asset.saved.title", message: "asset.saved.body", art: .illustration(.bloom),
                primary: KiraButton("asset.done") { model.finish() })
        }
        .kiraDialog(isPresented: hasFailure) { failureDialog }
    }

    private var navBar: some View {
        KiraNavBar(
            model.isUpdate ? "asset.update.title" : "asset.add.title", subtitle: "asset.subtitle",
            leading: .close("asset.close") { dismiss() })
    }

    private var form: some View {
        VStack(spacing: KiraSpacing.space4) {
            ScrollView {
                VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                    navBar
                    AssetClassGrid(model: model)
                    KiraField("asset.name", text: $model.name)
                        .hint("asset.name.hint")
                        .error(model.issue(in: .name)?.message)
                    KiraField("asset.value", text: $model.valueText)
                        .prefix("asset.currency").suffix("asset.cents").amount()
                        .hint("asset.value.hint")
                        .error(model.issue(in: .value)?.message)
                        .keyboardType(.numberPad)
                    AssetDayField(model: model)
                }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.top, KiraSpacing.space1)
                .background(alignment: .topTrailing) {
                    KiraLeaf(.twig, tone: .soft, size: 130, isFlipped: true)
                        .offset(x: 40, y: -36)
                        .accessibilityHidden(true)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            VStack(spacing: 12) {
                KiraNotice(.info, message: "asset.notice")
                KiraButton(model.isUpdate ? "asset.update.save" : "asset.save") { Task { await model.save() } }
                    .block()
                    .disabled(model.isSaving)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.bottom, KiraSpacing.space2)
        }
    }

    private var hasFailure: Binding<Bool> {
        Binding(get: { model.failure != nil }, set: { if !$0 { model.failure = nil } })
    }

    /** Coba Lagi on top, Tutup under it; the form keeps every field. */
    private var failureDialog: KiraDialog {
        KiraDialog(
            "asset.failed.title", message: failureMessage, art: .illustration(.umbrella),
            primary: KiraButton("asset.retry") { Task { await model.retry() } },
            secondary: KiraButton("ds.close", variant: .secondary) {})
    }

    private var failureMessage: LocalizedStringResource {
        guard let problem = model.failure else { return "asset.failed.body" }
        if problem.isConnectionLoss { return "asset.failed.body" }
        if problem.showsReference { return "sheet.failure.reference \(problem.reference)" }
        return problem.message
    }
}

#Preview {
    NavigationStack { AssetFormScreen(service: PreviewPortfolioService()) }
}
