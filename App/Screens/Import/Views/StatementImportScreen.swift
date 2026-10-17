/**
 Impor Mutasi (CAT-11, 11b): the format of the file with its sample to download, then the picker,
 the privacy promise and "Pilih File". Once a file is picked it is read on the device: a good file
 shows its card and "Lanjut Tinjau" (11b), a bad one the reason and "Pilih File Lain". "Lanjut
 Tinjau" sends the rows and opens Tinjau Hasil Impor (CAT-12).
 */
import Domain
import Features
import SwiftUI
import UniformTypeIdentifiers

struct StatementImportScreen: View {
    private let service: any HistoryService
    private let onOpen: (HistoryDestination) -> Void
    private let onFinish: () -> Void
    @State private var model: StatementImportModel
    @State private var picksFile = false
    @Environment(\.dismiss) private var dismiss

    /** `onFinish` returns to Riwayat, after a save or a cancel on the review. */
    init(service: any HistoryService, onOpen: @escaping (HistoryDestination) -> Void, onFinish: @escaping () -> Void) {
        self.service = service
        self.onOpen = onOpen
        self.onFinish = onFinish
        _model = State(initialValue: StatementImportModel(service: service))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("import.title", leading: .back("import.back") { dismiss() }) {
                    KiraHelpButton(.icon) { onOpen(.help) }
                }
                KiraStepProgress(current: 1, total: 3, label: stepLabel)
                header
                StatementFormatCard()
                StatementFileSection(model: model, pick: { picksFile = true }, openPlans: { onOpen(.plans) })
                KiraNotice(.privacy, message: "import.privacy")
                primaryButton.padding(.top, KiraSpacing.space2)
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
        .fileImporter(isPresented: $picksFile, allowedContentTypes: [.commaSeparatedText, .plainText]) { result in
            if case .success(let url) = result { model.choose(fileAt: url) } else { model.pickerFailed() }
        }
        .navigationDestination(item: $model.preview) { preview in
            ImportReviewScreen(
                preview: preview, fileName: model.fileName, service: service, onOpen: onOpen, onFinish: onFinish)
        }
    }

    private var stepLabel: LocalizedStringResource {
        if case .read = model.phase { return "import.step.chosen" }
        return "import.step.choose"
    }

    private var header: some View {
        HStack(spacing: KiraSpacing.space3) {
            VStack(alignment: .leading, spacing: 6) {
                Text("import.heading")
                    .font(KiraFont.display(24, .heavy, relativeTo: .title2))
                    .kiraLineHeight(30, size: 24, natural: 1.26, relativeTo: .title2)
                    .tracking(-0.48)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("import.lead").font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            KiraIllustration(.letter, size: 80)
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder private var primaryButton: some View {
        switch model.phase {
        case .choosing:
            KiraButton("import.pick") { picksFile = true }.icon(.file).block()
        case .read:
            KiraButton("import.continue") { Task { await model.continueToReview() } }.block()
                .disabled(model.isUploading)
        case .invalid:
            KiraButton("import.pickAnother") { picksFile = true }.icon(.file).block()
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            StatementImportScreen(service: PreviewHistoryService(), onOpen: { _ in }, onFinish: {})
        }
    }
#endif
