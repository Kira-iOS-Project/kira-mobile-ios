/**
 Ajukan Beasiswa (AKN-10, AKN-10b; boards BeasiswaKiraForm, BeasiswaKiraDialogKirim): what the
 person is facing (at least one chip), an optional story, and what is sent along. Kirim Pengajuan
 is simulated; Lihat Status on its dialog calls `onSent`.
 */
import Domain
import Features
import SwiftUI

struct ScholarshipApplyView: View {
    @State private var model: ScholarshipApplyModel
    private let onOpen: (AppRoute) -> Void
    private let onSent: () -> Void
    @Environment(\.dismiss) private var dismiss

    /** `draft` fills the form in, as BeasiswaKiraForm draws it (debug launches and previews). */
    init(
        service: any PlansService, draft: ScholarshipDraft? = nil, onOpen: @escaping (AppRoute) -> Void,
        onSent: @escaping () -> Void
    ) {
        let model = ScholarshipApplyModel(service: service)
        if let draft {
            draft.situations.forEach(model.toggle)
            model.story = draft.story
        }
        _model = State(initialValue: model)
        self.onOpen = onOpen
        self.onSent = onSent
    }

    var body: some View {
        PlansScreenFrame(leaf: .high) {
            KiraNavBar(
                "scholarship.apply.title", subtitle: "scholarship.title",
                leading: .back("scholarship.apply.back") {
                    dismiss()
                }
            ) {
                KiraHelpButton(.icon) { onOpen(.unavailable(.care)) }
            }
            PlansHeader("scholarship.apply.headline", subtitle: "scholarship.apply.lede", lineHeight: 32)
            situations
            KiraField("scholarship.apply.story", text: $model.story)
                .multiline(4)
                .hint("scholarship.apply.story.hint")
                .error(model.isStoryTooLong ? "scholarship.apply.story.tooLong" : nil)
            sentAlong
            Spacer(minLength: 0)
            VStack(spacing: KiraSpacing.space3) {
                KiraNotice(.info, title: "plans.prototype", message: "scholarship.prototype")
                if let problem = model.sendProblem { PlansProblemNotice(problem: problem) }
                PlansButtonRow(
                    secondary: KiraButton("scholarship.apply.cancel", variant: .secondary) { dismiss() },
                    primary: KiraButton("scholarship.apply.send") { Task { await model.send() } },
                    isPrimaryDisabled: !model.canSend
                )
            }
            .padding(.top, KiraSpacing.space2)
        }
        .task { await model.load() }
        .kiraDialog(isPresented: showsSent) {
            KiraDialog(
                "scholarship.sent.title", message: "scholarship.sent.body \(model.phase.value ?? "")",
                art: .illustration(.letter), primary: KiraButton("scholarship.sent.status", action: onSent))
        }
    }

    private var showsSent: Binding<Bool> {
        Binding(get: { model.sent != nil }, set: { if !$0 { model.sent = nil } })
    }

    private var situations: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("scholarship.apply.facing").font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
                Text("scholarship.apply.facing.hint").font(.footnote).kiraLineHeight(18, size: 13)
                    .foregroundStyle(.inkMuted)
            }
            .padding(.horizontal, KiraSpacing.space1)
            KiraFlowRow {
                ForEach(ScholarshipSituation.allCases, id: \.self) { situation in
                    KiraChip(situation.title, isSelected: model.situations.contains(situation)) {
                        model.toggle(situation)
                    }
                }
            }
        }
    }

    private var sentAlong: some View {
        KiraListGroup("scholarship.apply.sent", footer: "scholarship.apply.sent.footer") {
            KiraListRow(Text("scholarship.apply.sent.email"), leading: .icon(.send))
                .subtitle(Text("scholarship.apply.sent.email.detail \(model.phase.value ?? "")"))
            KiraListRow(Text("scholarship.apply.sent.mode"), leading: .icon(.check))
                .subtitle(Text("scholarship.apply.sent.mode.detail"))
        }
    }
}

/** What the person has already picked and written on the form. */
struct ScholarshipDraft {
    let situations: [ScholarshipSituation]
    let story: String
}
