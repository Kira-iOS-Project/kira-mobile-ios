/**
 Naskah Pengajuan Keringanan (PED-09, board NaskahNegosiasi): the lender (09b opens its list), the
 instalment it fills, what the person can pay, then the script with its two coloured phrases, the
 notice, and Lihat Simulasi beside Salin Naskah, whose toast says the script is copied, or, before
 both amounts are in, what is missing (the owner's call, 2026-10-18: a toast, not the 09c dialog).
 No help button, no mascot: a Kira Peduli screen.
 */
import Domain
import Features
import SwiftUI

struct NegotiationScriptScreen: View {
    private let onOpen: (AppRoute) -> Void
    @State private var model: NegotiationScriptModel
    @Environment(\.dismiss) private var dismiss

    init(service: any CareToolsService, onOpen: @escaping (AppRoute) -> Void) {
        self.onOpen = onOpen
        _model = State(
            initialValue: NegotiationScriptModel(
                service: service, defaultReason: String(localized: "care.script.reasonDefault"),
                copier: { KiraClipboard.copy(ScriptText.copied($0), copied: "care.script.copied") }))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.screenBottom)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 54, y: -28)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
        .kiraSheet(isPresented: isEditing, title: sheetTitle) { ScriptPhraseSheet(model: model) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            KiraIconButton.back("care.script.back") { dismiss() }
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                Text("care.script.title")
                    .font(KiraFont.display(28, .heavy, relativeTo: .largeTitle))
                    .kiraLineHeight(34, size: 28, natural: 1.26, relativeTo: .largeTitle)
                    .tracking(-0.56)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("care.script.lead").font(.body).kiraLineHeight(23, size: 17).foregroundStyle(.inkMuted)
            }
            .padding(.horizontal, KiraSpacing.space1)
        }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, KiraSpacing.space8)
        case .empty:
            form(debts: [])
        case .loaded(let debts):
            form(debts: debts)
        case .failed(let problem):
            LoadFailedView(problem: problem) { Task { await model.load() } }
        }
    }

    private func form(debts: [CareDebt]) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 14) {
                LenderPicker(model: model, debts: debts).zIndex(1)
                Group {
                    KiraField("care.script.instalment", text: $model.instalmentText)
                        .prefix("care.script.currency").suffix("care.script.cents").amount()
                        .keyboardType(.numberPad)
                    KiraField("care.script.affordable", text: $model.affordableText)
                        .prefix("care.script.currency").suffix("care.script.cents").amount()
                        .hint("care.script.affordableHint")
                        .keyboardType(.numberPad)
                }
                /** Covered by the open lender list, the fields leave VoiceOver until a lender is picked. */
                .accessibilityHidden(model.isPickingLender)
            }
            ScriptCard(model: model)
            KiraNotice(.info, message: "care.script.notice")
            KiraButtonPair(
                secondary: KiraButton("care.script.simulation", variant: .secondary, size: .small) {
                    onOpen(.payoffSimulation)
                },
                primary: KiraButton("care.script.copy", size: .small, action: copyScript).icon(.copy)
            )
            /** Both stay enabled, as the board draws them; Salin Naskah copies nothing until the script is complete. */
            .padding(.top, KiraSpacing.space2)
        }
    }

    /** Salin Naskah: the copier's toast says it is copied; an incomplete script says what to fill. */
    private func copyScript() {
        if !model.copy() {
            KiraToastCenter.shared.show(KiraToast(tone: .failure, message: "care.script.copy.incomplete"))
        }
    }

    private var sheetTitle: LocalizedStringResource {
        model.editing == .contract ? "care.script.contract.title" : "care.script.reason.title"
    }

    private var isEditing: Binding<Bool> {
        Binding(get: { model.editing != nil }, set: { if !$0 { model.editing = nil } })
    }

}

#if DEBUG
    #Preview {
        NavigationStack { NegotiationScriptScreen(service: PreviewCareToolsService()) { _ in } }
    }
#endif
